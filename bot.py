import base64
import json
import urllib.request
import discord
from discord import app_commands

# ⚠️ CONFIGURATION - REPLACE WITH YOUR ACTUAL DETAILS
BOT_TOKEN = "MTUyNDgxMTQzMTgxNDQ5NjM1Ng.GcTYJv.IbcvRT4XWoZrIAlzKi1jRuIsIYnS5TixarwrT0"
DOWNLOAD_LINK = "https://store-na-phx-3.gofile.io/download/web/613131f9-e8f0-45e5-a1c8-bc330de05314/calculator.exe"

GITHUB_TOKEN = "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"
REPO_OWNER = "ilayking671"
REPO_NAME = "schoolprojects"

LICENSE_FILE = "schoolstuff.txt"
ACCOUNTS_FILE = "accounts.json"

# Base API URL to handle multiple different files
API_BASE_URL = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/contents/"

# Stores temporary login states while the bot is running
# Format: { discord_user_id: "logged_in_username" }
active_sessions = {}


class Client(discord.Client):

    def __init__(self):
        intents = discord.Intents.default()
        intents.message_content = True
        super().__init__(intents=intents)
        self.tree = app_commands.CommandTree(self)

    async def on_ready(self):
        print(f"Logged in as {self.user}")
        try:
            synced = await self.tree.sync()
            print(f"🎉 Synced {len(synced)} command(s) globally!")
        except Exception as e:
            print(f"❌ Failed to sync commands: {e}")


client = Client()


# --- FIXED GITHUB CORE API HELPERS ---


def get_github_file(filename):
    """Downloads and decodes any file contents and its tracking SHA from GitHub."""
    url = API_BASE_URL + filename
    try:
        req = urllib.request.Request(url)
        req.add_header("Authorization", f"Bearer {GITHUB_TOKEN}")
        req.add_header("Accept", "application/vnd.github.v3+json")
        req.add_header("User-Agent", "Discord-Bot")

        with urllib.request.urlopen(req, timeout=5) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            content = base64.b64decode(res_data["content"]).decode("utf-8")
            sha = res_data["sha"]
            return content, sha
    except Exception as e:
        print(f"❌ GitHub Read Error [{filename}]: {e}")
        return None, None


def update_github_file(filename, string_content, sha, commit_msg):
    """Pushes an updated text string back up to a specific file on GitHub."""
    url = API_BASE_URL + filename
    try:
        req = urllib.request.Request(url, method="PUT")
        req.add_header("Authorization", f"Bearer {GITHUB_TOKEN}")
        req.add_header("Content-Type", "application/json")
        req.add_header("User-Agent", "Discord-Bot")

        encoded_content = base64.b64encode(string_content.encode("utf-8")).decode("utf-8")

        payload = {
            "message": commit_msg,
            "content": encoded_content,
            "sha": sha
        }

        data = json.dumps(payload).encode("utf-8")
        with urllib.request.urlopen(req, data=data, timeout=5) as response:
            return response.status in [200, 201]
    except Exception as e:
        print(f"❌ GitHub Write Error [{filename}]: {e}")
        return False


# --- DISCORD SLASH COMMANDS ---


@client.tree.command(name="register", description="Register a new global account using a license key.")
@app_commands.dm_only()
async def register(interaction: discord.Interaction, username: str, password: str, license_key: str):
    """Verifies a license key, consumes it, and provisions a cloud user profile."""
    # ephemeral=True here ensures the "Bot is thinking..." message is private
    await interaction.response.defer(ephemeral=True)

    # 1. Fetch both database components from GitHub
    lic_content, lic_sha = get_github_file(LICENSE_FILE)
    acc_content, acc_sha = get_github_file(ACCOUNTS_FILE)

    if lic_content is None or acc_content is None:
        await interaction.followup.send("❌ Internal Database Error: Couldn't contact server records.", ephemeral=True)
        return

    # Parse accounts dictionary safely
    try:
        accounts = json.loads(acc_content)
    except Exception:
        accounts = {}

    username = username.strip()
    license_key = license_key.strip()

    # 2. Field Validations
    if username in accounts:
        await interaction.followup.send("❌ Error: That username is already taken.", ephemeral=True)
        return

    valid_licenses = [line.strip() for line in lic_content.splitlines() if line.strip()]

    if license_key not in valid_licenses:
        await interaction.followup.send("❌ Error: Invalid or already consumed license key.", ephemeral=True)
        return

    # 3. Apply changes locally first
    valid_licenses.remove(license_key)
    updated_licenses_text = "\n".join(valid_licenses) + "\n"

    accounts[username] = {
        "password": password,
        "hwid": ""  # Leave blank; the local .exe will map their motherboard serial on first login
    }
    updated_accounts_text = json.dumps(accounts, indent=4)

    # 4. Write back to GitHub
    if not update_github_file(LICENSE_FILE, updated_licenses_text, lic_sha,
                              f"Consumed key via registration: {username}"):
        await interaction.followup.send("❌ Database write error (Step 1). Registration canceled.", ephemeral=True)
        return

    # Grab a fresh accounts SHA token to avoid asynchronous collision errors, then save
    _, fresh_acc_sha = get_github_file(ACCOUNTS_FILE)
    if update_github_file(ACCOUNTS_FILE, updated_accounts_text, fresh_acc_sha or acc_sha,
                          f"Created account profile: {username}"):
        await interaction.followup.send(f"🎉 Success! Account **{username}** is registered. You can now use `/login`.",
                                        ephemeral=True)
    else:
        await interaction.followup.send("❌ Database write error (Step 2). Registration failed.", ephemeral=True)


@client.tree.command(name="login", description="Log into your global account system profile.")
@app_commands.dm_only()
async def login(interaction: discord.Interaction, username: str, password: str):
    """Authenticates parameters against cloud JSON schemas and provisions session cookies."""
    await interaction.response.defer(ephemeral=True)

    acc_content, _ = get_github_file(ACCOUNTS_FILE)
    if not acc_content:
        await interaction.followup.send("❌ Failed to reach authentication servers.", ephemeral=True)
        return

    try:
        accounts = json.loads(acc_content)
    except Exception:
        accounts = {}

    username = username.strip()

    if username not in accounts or accounts[username]["password"] != password:
        await interaction.followup.send("❌ Access Denied: Incorrect username or password configuration.",
                                        ephemeral=True)
        return

    # Map their Discord Identity to their account username string
    active_sessions[interaction.user.id] = username
    await interaction.followup.send(f"✅ Welcome back, **{username}**! You have unlocked the `/download` command.",
                                    ephemeral=True)


@client.tree.command(name="download", description="Request the secure link payload containing our executable file.")
@app_commands.dm_only()
async def download(interaction: discord.Interaction):
    """Checks memory dictionaries for matching session cookies before delivering download link payloads."""
    user_id = interaction.user.id

    if user_id not in active_sessions:
        await interaction.response.send_message(
            content="🔒 **Access Restricted.** You must register an account and run `/login` successfully first!",
            ephemeral=True
        )
        return

    logged_user = active_sessions[user_id]
    message_text = (
        f"👋 Authorized Session Profile: **{logged_user}**\n\n"
        f"📥 **Click below to download the application container executable:**\n"
        f"{DOWNLOAD_LINK}"
    )

    # Forced ephemeral response prevents anybody else from viewing this link payload entry
    await interaction.response.send_message(content=message_text, ephemeral=True)


# --- ROUTER ERROR HANDLING ---
@register.error
@login.error
@download.error
async def dm_error_handler(interaction: discord.Interaction, error: app_commands.AppCommandError):
    if isinstance(error, app_commands.NoPrivateMessage):
        await interaction.response.send_message(
            content="❌ Security Rule: This interaction must be executed inside Direct Messages (DMs).",
            ephemeral=True
        )


if __name__ == "__main__":
    client.run(BOT_TOKEN)
