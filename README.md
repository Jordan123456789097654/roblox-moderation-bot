# ROBLOX Discord Moderation Bot

TypeScript Discord slash-command bot for Roblox moderation through Open Cloud.

## Setup

1. Install dependencies:

   ```bash
   npm install
   ```

2. Copy `.env.example` to `.env` and fill in your Discord and Roblox values. Generate a unique `ROBLOX_MESSAGING_SHARED_SECRET` with at least 32 characters; it is required for kick messages.

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

6. Put `RobloxScript/ModerationMessaging.server.lua` in `ServerScriptService`, then set its `TOPIC` and `MODERATION_SHARED_SECRET` to the same values as `config.json` and `.env` respectively.

   The script accepts only version 1 kick messages, discards messages older than 90 seconds, and ignores duplicate request IDs for 90 seconds. Keep the MessagingService publish permission on a dedicated, least-privileged API key.

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

## Security notes

- The bot only accepts `/game` interactions from `DISCORD_GUILD_ID`, even if it is installed elsewhere.
- Restrict `logsChannelId` to trusted staff: moderation targets and action outcomes are posted there.
- Do not share the Roblox API key. It can publish moderation messages and change user restrictions for the configured universe.
- Keep the Roblox script's `TOPIC` and `config.json` synchronized. A unique topic name is recommended to prevent accidental cross-feature messages.
- Keep `ROBLOX_MESSAGING_SHARED_SECRET` out of Git and set the identical value in the Roblox server script. The listener fails closed until it is configured.

## Love this?

- Consider giving it a star for support! 
