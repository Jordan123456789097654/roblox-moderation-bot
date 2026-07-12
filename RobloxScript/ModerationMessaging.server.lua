local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local TOPIC = "DiscordModeration"
local MAX_MESSAGE_AGE_SECONDS = 90
local processedRequestIds = {}

local function cleanProcessedRequestIds(now)
	for requestId, expiresAt in pairs(processedRequestIds) do
		if expiresAt <= now then
			processedRequestIds[requestId] = nil
		end
	end
end

local function findPlayerByUserId(userId)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.UserId == userId then
			return player
		end
	end

	return nil
end

local function handleMessage(message)
	local now = os.time()
	local sentAt = tonumber(message.Sent)
	if not sentAt or math.abs(now - sentAt) > MAX_MESSAGE_AGE_SECONDS then
		warn("[DiscordModeration] Ignored stale moderation payload")
		return
	end

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

	if payload.version ~= 1 or payload.action ~= "kick" then
		return
	end

	local userId = tonumber(payload.userId)
	if not userId or userId <= 0 or userId % 1 ~= 0 then
		warn("[DiscordModeration] Kick payload missing userId")
		return
	end

	local requestId = payload.requestId
	if typeof(requestId) ~= "string" or #requestId ~= 36 or not string.match(requestId, "^[%x%-]+$") then
		warn("[DiscordModeration] Kick payload missing requestId")
		return
	end

	if typeof(payload.reason) ~= "string" or #payload.reason > 512 then
		warn("[DiscordModeration] Kick payload has invalid reason")
		return
	end

	cleanProcessedRequestIds(now)
	if processedRequestIds[requestId] then
		return
	end
	processedRequestIds[requestId] = now + MAX_MESSAGE_AGE_SECONDS

	local player = findPlayerByUserId(userId)
	if player then
		player:Kick(payload.reason)
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
