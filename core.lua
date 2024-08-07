local function onShow(self)
	self.editBox:SetScript("OnKeyDown",function(self,key)
		if key == "C" and IsControlKeyDown() then
			C_Timer.After(0.1,function()
				StaticPopup_Hide("COPY_MOUNT_NAME")
			end)

			self.editBox:SetScript("OnKeyDown",nil)
		end
  end)
  self.editBox:SetText(self.text.text_arg1 or "")
  self.editBox:HighlightText()
  self.editBox:SetFocus()
end

StaticPopupDialogs["COPY_MOUNT_NAME"] = {
	hasEditBox = true,
	OnShow = onShow,
	text = "Press Ctrl+C!",
	button1 = "OK",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	showAlert = true,
}

local function showCopyPopup(str)
	if str and str ~= "" then
		StaticPopup_Show("COPY_MOUNT_NAME",str)
	else
		print("No mount name found")
	end
end

local function mountMenuHook(owner, rootDescription)
	if not owner.mountID then return end
	local name = C_MountJournal.GetMountInfoByID(owner.mountID);
	rootDescription:CreateDivider();
	rootDescription:CreateTitle("My Addon");
	rootDescription:CreateButton("Copy mount name", showCopyPopup, name)
end

Menu.ModifyMenu("MENU_MOUNT_COLLECTION_MOUNT",mountMenuHook)
