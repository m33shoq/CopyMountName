local function onShow(self)
	self.editBox:SetScript("OnKeyDown",function(_,key)
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
}

local function showCopyPopup(str)
	if str and str ~= "" then
		StaticPopup_Show("COPY_MOUNT_NAME",str)
	else
		print("No mount name found")
	end
end

local function mountMenuHook(owner, rootDescription)
    local mountID = owner.mountID or owner:GetParent().mountID
	if not mountID then return end
	local name = C_MountJournal.GetMountInfoByID(mountID);
	rootDescription:CreateDivider();
	rootDescription:CreateButton("Copy mount name", showCopyPopup, name)
end

Menu.ModifyMenu("MENU_MOUNT_COLLECTION_MOUNT",mountMenuHook)


local function CreateContextMenu(owner, rootDescription, index)
	rootDescription:SetTag("MENU_MOUNT_COLLECTION_MOUNT_HOOKED");

    local name = C_MountJournal.GetDisplayedMountInfo(index);
	rootDescription:CreateButton("Copy mount name", showCopyPopup, name)
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections", function()
    local function onClick(self, button)
        if button ~= "LeftButton" then
            local index = self.index or self:GetParent().index
            local isCollected = select(11, C_MountJournal.GetDisplayedMountInfo(index));
            if not isCollected then -- blizzard won't show the context menu for uncollected mounts
                MenuUtil.CreateContextMenu(self, CreateContextMenu, index);
            end
        end
    end

    hooksecurefunc("MountListItem_OnClick", onClick)
end)

