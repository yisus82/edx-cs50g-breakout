--[[
  Used as the base class for all of our states, so we don't have to
  define empty methods in each of them. StateMachine requires each
  state have a set of four "interface" methods that it can reliably call,
  so by inheriting from this base state, our state classes will all have
  at least empty versions of these methods even if we don't define them
  ourselves in the actual classes.
]]

Base = Class {}

function Base:init() end

function Base:enter(_enterParams) end

function Base:exit() end

function Base:update(_dt) end

function Base:render() end
