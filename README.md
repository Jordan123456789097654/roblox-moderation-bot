# ROBLOX Discord Moderation Bot

TypeScript Discord slash-command bot for Roblox moderation through Open Cloud.

## Setup

1. Install dependencies:

   ```bash
   npm install
   ```

2. Copy `.env.example` to `.env` and fill in your Discord and Roblox values.

3. Edit `config.json`:

   - `embedColor`: hex color without `#`, default `393A43`
   - `logsChannelId`: Discord channel for audit logs
   - `whitelistedRoles`: Discord role IDs that can use commands
   - `whitelistedUsers`: Discord user IDs that can use commands
   - `whitelistedRobloxUsers`: Roblox user IDs protected from moderation
   - `messagingTopic`: MessagingService topic used by the Roblox script

4. Register slash commands:

   ```bash
   npm run register
   ```

5. Start the bot:

   ```bash
   npm run dev
   ```

6. Put `RobloxScript/ModerationMessaging.server.lua` in `ServerScriptService` and make sure its `TOPIC` matches `config.json`.

## Commands

- `/game kick username reason`
- `/game ban username banalts duration reason`
- `/game banlist`
- `/game unban username reason`
- `/game restartservers`

State-changing commands require a confirmation button before the Roblox action runs.
Reasons are limited to 512 characters so Open Cloud MessagingService kick payloads stay under Roblox's 1 KiB message limit.

## Roblox Open Cloud Scopes

Your API key needs permissions for:

- MessagingService publish
- User restrictions read/write
- Universe restart
- User lookup if using Open Cloud user lookup
