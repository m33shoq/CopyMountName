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
		print("No name found")
	end
end

-- mount collection
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

-- achievements
EventUtil.ContinueOnAddOnLoaded("Blizzard_AchievementUI", function ()

    local function CreateContextMenu(owner, rootDescription)
        rootDescription:SetTag("MENU_ACHIEVEMENT_COLLECTION_MOUNT_HOOKED");

        local _, achievementName, points, completed, month, day, year, description, flags, iconpath = GetAchievementInfo(owner.id);
        rootDescription:CreateButton("Copy achievement name", showCopyPopup, achievementName)
    end

    local _ProcessClick = AchievementTemplateMixin.ProcessClick
    function AchievementTemplateMixin:ProcessClick(buttonName, down) -- i am horrified at taint possibilities
        if buttonName == "RightButton" then
            MenuUtil.CreateContextMenu(self, CreateContextMenu);
        else
            _ProcessClick(self, buttonName, down)
        end
	end

    hooksecurefunc(AchievementTemplateMixin, "OnLoad", function (self)
        self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    end)

end)

-- pet collection
local function petMenuHook(owner, rootDescription)
    local petID = owner.petID or owner:GetParent().petID
	if not petID then return end
	local name = select(8, C_PetJournal.GetPetInfoByPetID(petID));
	rootDescription:CreateDivider();
	rootDescription:CreateButton("Copy pet name", showCopyPopup, name)
end

Menu.ModifyMenu("MENU_PET_COLLECTION_PET",petMenuHook)

local function CreateContextMenu(owner, rootDescription, index)
	rootDescription:SetTag("MENU_PET_COLLECTION_PET_HOOKED");

    local name = select(8, C_PetJournal.GetPetInfoByIndex(index));
	rootDescription:CreateButton("Copy pet name", showCopyPopup, name)
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections", function() -- clicking on the uncollected pet invokes a lag
    local function onClick(self, button)
        if button == "RightButton"  then
            local index = self.index or self:GetParent().index
            local owned = self.owned or self:GetParent().owned

            if not owned then -- blizzard won't show the context menu for uncollected pets
                MenuUtil.CreateContextMenu(self, CreateContextMenu, index);
            end
        end
    end

    hooksecurefunc("PetJournal_InitPetButton", function(self)
        self:HookScript("OnClick", onClick)
    end)
end)
