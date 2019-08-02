--- **AI** -- (R2.4) - Models the assignment of AI escorts to player flights upon request using the radio menu.
--
-- ## Features:
-- --     
--   * Provides the facilities to trigger escorts when players join flight units.
--   * Provide different means how escorts can be triggered:
--     * Directly when a player joins a plane.
--     * Through the menu.
-- 
-- ===
-- 
-- ## Test Missions:
-- 
-- Test missions can be located on the main GITHUB site.
-- 
-- [FlightControl-Master/MOOSE_MISSIONS]
-- 
-- ===
-- 
-- ===
-- 
-- ### Author: **FlightControl**
-- 
-- ===       
--
-- @module AI.AI_ESCORT_DISPATCHER_REQUEST
-- @image AI_ESCORT_DISPATCHER_REQUEST.JPG


--- @type AI_ESCORT_DISPATCHER_REQUEST
-- @field Core.Set#SET_GROUP CarrierSet The set of @{Wrapper.Group#GROUP} objects of carriers that will transport the cargo. 
-- @field Core.Set#SET_GROUP EscortGroupSet The set of group AI escorting the EscortUnit.
-- @field #string EscortName Name of the escort.
-- @field #string EscortBriefing A text showing the AI_ESCORT briefing to the player. Note that if no EscortBriefing is provided, the default briefing will be shown.
-- @extends Core.Fsm#FSM


--- A dynamic cargo handling capability for AI groups.
-- 
-- ===
--   
-- @field #AI_ESCORT_DISPATCHER_REQUEST
AI_ESCORT_DISPATCHER_REQUEST = {
  ClassName = "AI_ESCORT_DISPATCHER_REQUEST",
}

--- @field #list 
AI_ESCORT_DISPATCHER_REQUEST.AI_Escorts = {}


--- Creates a new AI_ESCORT_DISPATCHER_REQUEST object.
-- @param #AI_ESCORT_DISPATCHER_REQUEST self
-- @param Core.Set#SET_GROUP CarrierSet The set of @{Wrapper.Group#GROUP} objects of carriers that will transport the cargo. 
-- @param Core.Spawn#SPAWN EscortSpawn The spawn object that will spawn in the Escorts.
-- @param Wrapper.Airbase#AIRBASE EscortAirbase The airbase where the escorts are spawned.
-- @param #string EscortName Name of the escort.
-- @param #string EscortBriefing A text showing the AI_ESCORT briefing to the player. Note that if no EscortBriefing is provided, the default briefing will be shown.
-- @return #AI_ESCORT_DISPATCHER_REQUEST
function AI_ESCORT_DISPATCHER_REQUEST:New( CarrierSet, EscortSpawn, EscortAirbase, EscortName, EscortBriefing )

  local self = BASE:Inherit( self, FSM:New() ) -- #AI_ESCORT_DISPATCHER_REQUEST

  self.CarrierSet = CarrierSet
  self.EscortSpawn = EscortSpawn
  self.EscortAirbase = EscortAirbase
  self.EscortName = EscortName
  self.EscortBriefing = EscortBriefing

  self:SetStartState( "Idle" ) 
  
  self:AddTransition( "Monitoring", "Monitor", "Monitoring" )

  self:AddTransition( "Idle", "Start", "Monitoring" )
  self:AddTransition( "Monitoring", "Stop", "Idle" )
  
  -- Put a Dead event handler on CarrierSet, to ensure that when a carrier is destroyed, that all internal parameters are reset.
  function self.CarrierSet.OnAfterRemoved( CarrierSet, From, Event, To, CarrierName, Carrier )
    self:F( { Carrier = Carrier:GetName() } )
  end
  
  return self
end

function AI_ESCORT_DISPATCHER_REQUEST:onafterStart( From, Event, To )

  self:HandleEvent( EVENTS.Birth )
  
  self:HandleEvent( EVENTS.PlayerLeaveUnit )

end


--- @param #AI_ESCORT_DISPATCHER_REQUEST self
-- @param Core.Event#EVENTDATA EventData
function AI_ESCORT_DISPATCHER_REQUEST:OnEventBirth( EventData )

  local PlayerGroupName = EventData.IniGroupName
  local PlayerGroup = EventData.IniGroup
  local PlayerUnit = EventData.IniUnit
  
  self:I({PlayerGroupName = PlayerGroupName } )
  self:I({PlayerGroup = PlayerGroup})
  self:I({FirstGroup = self.CarrierSet:GetFirst()})
  self:I({FindGroup = self.CarrierSet:FindGroup( PlayerGroupName )})
  
  if self.CarrierSet:FindGroup( PlayerGroupName ) then
    if not self.AI_Escorts[PlayerGroupName] then
      local LeaderUnit = PlayerUnit
      self:ScheduleOnce( 0.1,
        function()
          self.AI_Escorts[PlayerGroupName] = AI_ESCORT_REQUEST:New( LeaderUnit, self.EscortSpawn, self.EscortAirbase, self.EscortName, self.EscortBriefing )
          self.AI_Escorts[PlayerGroupName]:FormationTrail( 0, 100, 0 )
          if PlayerGroup:IsHelicopter() then
            self.AI_Escorts[PlayerGroupName]:MenusHelicopters()
          else
            self.AI_Escorts[PlayerGroupName]:MenusAirplanes()
          end
          self.AI_Escorts[PlayerGroupName]:__Start( 0.1 )
        end
      )
    end
  end

end


--- Start Trigger for AI_ESCORT_DISPATCHER_REQUEST
-- @function [parent=#AI_ESCORT_DISPATCHER_REQUEST] Start
-- @param #AI_ESCORT_DISPATCHER_REQUEST self

--- Start Asynchronous Trigger for AI_ESCORT_DISPATCHER_REQUEST
-- @function [parent=#AI_ESCORT_DISPATCHER_REQUEST] __Start
-- @param #AI_ESCORT_DISPATCHER_REQUEST self
-- @param #number Delay

--- Stop Trigger for AI_ESCORT_DISPATCHER_REQUEST
-- @function [parent=#AI_ESCORT_DISPATCHER_REQUEST] Stop
-- @param #AI_ESCORT_DISPATCHER_REQUEST self

--- Stop Asynchronous Trigger for AI_ESCORT_DISPATCHER_REQUEST
-- @function [parent=#AI_ESCORT_DISPATCHER_REQUEST] __Stop
-- @param #AI_ESCORT_DISPATCHER_REQUEST self
-- @param #number Delay






