class 'AdvancedChatMessages'

function AdvancedChatMessages:__init()
	-- Subscribe to events.
	self.m_EngineMessageEvent = Events:Subscribe('Engine:Message', self, self.OnEngineMessage)
end

function AdvancedChatMessages:OnEngineMessage(p_Message)
	if p_Message == nil then
		return
	end

	-- We only care about UIHudChatMessages.
	if p_Message.category ~= MessageCategory.UI or p_Message.type ~= MessageType.UIHudChatMessage then
		return
	end

	-- Get the message, process it and pass it to our custom 
	-- WebUI package for rendering.
	local s_Message = UIHudChatMessage(p_Message)
	
	if s_Message.channel == ChatChannelType.Admin then
		-- This is a workaround because many RCON tools prepend
		-- "Admin: " to admin messages.
		local s_String = s_Message.string:gsub("^Admin: ", '')

		WebUI:ExecuteJS(string.format('AdvancedChat.trigger("message:all", "Admin", %s);', WebUI:QuoteString(s_String)))
		return
	end

	-- Get the player sending the message, and our local player.
	local s_OtherPlayer = s_Message.sender
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	-- Players not found; cancel.
	if s_OtherPlayer == nil or s_LocalPlayer == nil then
		return
	end

	-- Player is a spectator.
	if s_OtherPlayer.teamID == 0 then
		WebUI:ExecuteJS(string.format('AdvancedChat.trigger("message:spectator", %s, %s);', WebUI:QuoteString(s_OtherPlayer.name), WebUI:QuoteString(s_Message.string)))
		return
	end

	-- Player is on a different team; display enemy message.
	if (s_LocalPlayer.teamID == 0 and s_OtherPlayer.teamID == 2) or (s_LocalPlayer.teamID ~= 0 and s_OtherPlayer.teamID ~= s_LocalPlayer.teamID) then
		WebUI:ExecuteJS(string.format('AdvancedChat.trigger("message:enemy", %s, %s);', WebUI:QuoteString(s_OtherPlayer.name), WebUI:QuoteString(s_Message.string)))
		return
	end

	-- Player is in the same team.
	-- Display global message.
	if s_Message.channel == ChatChannelType.SayAll and s_LocalPlayer.teamID ~= 0 then
		WebUI:ExecuteJS(string.format('AdvancedChat.trigger("message:all", %s, %s);', WebUI:QuoteString(s_OtherPlayer.name), WebUI:QuoteString(s_Message.string)))
		return
	end

	-- Display team message.
	if s_Message.channel == ChatChannelType.Team or s_LocalPlayer.teamID == 0 then
		WebUI:ExecuteJS(string.format('AdvancedChat.trigger("message:team", %s, %s);', WebUI:QuoteString(s_OtherPlayer.name), WebUI:QuoteString(s_Message.string)))
		return
	end

	-- Display squad message.
	if s_Message.channel == ChatChannelType.Squad or s_Message.channel == ChatChannelType.SquadLeader then
		WebUI:ExecuteJS(string.format('AdvancedChat.trigger("message:squad", %s, %s);', WebUI:QuoteString(s_OtherPlayer.name), WebUI:QuoteString(s_Message.string)))
		return
	end

	return
end

return AdvancedChatMessages