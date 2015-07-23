local PLUGIN = nil

function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function hasbit(x, p)
  return x % (p + p) >= p       
end

function setbit(x, p)
  return hasbit(x, p) and x or x + p
end

function clearbit(x, p)
  return hasbit(x, p) and x - p or x
end

function Initialize(Plugin)
	PLUGIN = Plugin

	PLUGIN:SetName("Leaf Decay Prevention")
	PLUGIN:SetVersion(1)

	cPluginManager.AddHook(cPluginManager.HOOK_CHUNK_AVAILABLE, OnChunkAvailable)

	return true
end

local UpdatedChunks = {}

-- Prevent leaves from decaying by turning them all into player-placed leaves. Don't go over already checked chunks
function OnChunkAvailable(World, CX, CZ)
	local key = CX .. "," .. CZ
	if UpdatedChunks[key] == nil then
		local ChunkX = CX * 16
		local ChunkZ = CZ * 16
		for y = 0,255 do
			for x = 0,15 do
				for z = 0,15 do
					local _, Type, Meta = World:GetBlockInfo(ChunkX + x, y, ChunkZ + z)
					if Type == E_BLOCK_LEAVES and not hasbit(Meta, bit(3)) then
						Meta = setbit(Meta, bit(3))
						World:SetBlockMeta(ChunkX + x, y, ChunkZ + z, Meta)
					end
				end
			end
		end
		UpdatedChunks[key] = true
	end
end