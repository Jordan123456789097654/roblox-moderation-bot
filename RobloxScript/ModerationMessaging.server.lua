local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local TOPIC = "DiscordModeration"

local function findPlayerByUserId(userId)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.UserId == userId then
			return player
		end
	end

	return nil
end

local function handleMessage(message)
	local ok, payload = pcall(function()
		if typeof(message.Data) == "string" then
			return HttpService:JSONDecode(message.Data)
		end

		return message.Data
	end)

	if not ok or typeof(payload) ~= "table" then
		warn("[DiscordModeration] Invalid moderation payload")
		return
	end

	if payload.action ~= "kick" then
		return
	end

	local userId = tonumber(payload.userId)
	if not userId then
		warn("[DiscordModeration] Kick payload missing userId")
		return
	end

	local player = findPlayerByUserId(userId)
	if player then
		player:Kick(tostring(payload.reason or "You were kicked by a moderator."))
	end
end

local success, connectionOrError = pcall(function()
	return MessagingService:SubscribeAsync(TOPIC, handleMessage)
end)

if success then
	print("[DiscordModeration] Subscribed to topic:", TOPIC)
else
	warn("[DiscordModeration] Failed to subscribe:", connectionOrError)
end
