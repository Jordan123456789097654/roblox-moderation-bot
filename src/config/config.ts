import { z } from "zod";
import dotenv from "dotenv";

dotenv.config();

const snowflakeSchema = z.string().regex(/^\d+$/, "Discord IDs must be numeric strings");

const robloxUserIdSchema = z.union([
  z.string().regex(/^\d+$/),
  z.number().int().positive()
]).transform((value) => String(value));

const configSchema = z.object({
  embedColor: z.string().regex(/^[0-9a-fA-F]{6}$/).default("393A43"),

  logsChannelId: z.union([
    snowflakeSchema,
    z.literal("")
  ]).default(process.env.LOGS_CHANNEL_ID ?? ""),

  whitelistedRoles: z.array(snowflakeSchema).default([]),

  whitelistedUsers: z.array(snowflakeSchema).default([]),

  whitelistedRobloxUsers: z.array(robloxUserIdSchema).default([]),

  messagingTopic: z.string()
    .min(1)
    .max(80)
    .default(process.env.ROBLOX_MESSAGING_TOPIC ?? "DiscordModeration"),

  discordToken: z.string().min(1),
  discordClientId: z.string().min(1),
  discordGuildId: z.string().min(1),

  robloxOpenCloudApiKey: z.string().min(1),
  robloxMessagingSharedSecret: z.string().min(32)
});

export type BotConfig = z.infer<typeof configSchema>;

export function parseConfig(value: unknown): BotConfig {
  return configSchema.parse(value);
}

export function loadConfig(): BotConfig {
  return parseConfig({
    discordToken: process.env.DISCORD_TOKEN,
    discordClientId: process.env.DISCORD_CLIENT_ID,
    discordGuildId: process.env.DISCORD_GUILD_ID,

    robloxOpenCloudApiKey: process.env.ROBLOX_OPEN_CLOUD_API_KEY,
    robloxMessagingSharedSecret: process.env.ROBLOX_MESSAGING_SHARED_SECRET,

    logsChannelId: process.env.LOGS_CHANNEL_ID ?? "",
    messagingTopic: process.env.ROBLOX_MESSAGING_TOPIC ?? "DiscordModeration"
  });
}

export function embedColorNumber(
  config: Pick<BotConfig, "embedColor">
): number {
  return Number.parseInt(config.embedColor, 16);
}
