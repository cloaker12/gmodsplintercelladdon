

util.AddNetworkString( "SelectWeapon" )
util.AddNetworkString( "SelectEquipment" )
util.AddNetworkString( "SelectEquipment2" )

local PLY = FindMetaTable( "Player" )

function PLY:SetEquipment( equip )
	self.Equipment[ 1 ] = equip
	print( type( equip ) )
	self:SetNWString( "Equipment1", equip )
end

function PLY:SetEquipment2( equip )
	self.Equipment[ 2 ] = equip
	print( type( equip ) )
	self:SetNWString( "Equipment2", equip )
end
 
function PLY:SetSelectedWeapon( wep )
	self.SelectedWeapon = wep
end

function PLY:GetSelectedWeapon()
	return self.SelectedWeapon 
end

function PLY:SetUpLoadout()
	self.Equipment = {}
	-- Don't auto-select random equipment and weapons - let players choose via F2 menu
	-- But provide default weapon if none selected
	if not self.SelectedWeapon then
		self:SetSelectedWeapon("weapon_hdn_m16") -- Default weapon
	end
	self.Data = {}
end

function PLY:ApplyLoadOut()
	hook.Call( "OnLoadoutGiven", GAMEMODE, self, self:GetSelectedWeapon()  )
end

net.Receive( "SelectWeapon", function( len, ply ) 
	ply:SetSelectedWeapon( net.ReadString() )
end)

net.Receive( "SelectEquipment", function( len, ply )
	ply.TempEquipment1 = net.ReadString()
end)

net.Receive( "SelectEquipment2", function( len, ply )
	ply.TempEquipment2 = net.ReadString()
end)