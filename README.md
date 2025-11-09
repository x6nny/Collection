# 🧩 Collection Utility for Roblox Studio (Luau)

A lightweight, type-safe wrapper around Roblox’s [`CollectionService`](https://create.roblox.com/docs/reference/engine/classes/CollectionService) for managing instance tags and tag-based events in **Luau**.
This module simplifies handling tagged instances, automatically managing connections for added and removed tags with optional ancestor filtering.

---

## 🚀 Features

* ✅ Type-safe with `--!strict` Luau typing
* 🔖 Easily **add**, **remove**, and **check** tags
* 🧠 Subscribe to **tag added** and **tag removed** events
* 🌳 Supports **ancestor filtering** to limit event callbacks to specific hierarchies
* ⚙️ Automatically manages signal connections to prevent memory leaks

---

## 📘 API Summary

| Method                                        | Description                                                                            | Returns                                                      |           |
| --------------------------------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------ | --------- |
| `Collection(tagName: string)`                 | Creates a new collection object for the given tag                                      | `Collection`                                                 |           |
| `collection:GetTagged()`                      | Returns all instances currently tagged                                                 | `{ Instance }`                                               |           |
| `collection:AddTag(instance: Instance)`       | Adds the tag to one or more instances                        							 | `()`      													|
| `collection:RemoveTag(instance: Instance)`    | Removes the tag from one or more instances                   							 | `()`      													|
| `collection:HasTag(instance: Instance)`       | Checks whether an instance or table of instances has the tag 							 | `boolean` 													|
| `collection:tagAdded(callback, ancestors?)`   | Connects a listener for when a tagged instance is added; optional ancestor filtering   | `() -> ()` (disconnect function)                             |           |
| `collection:tagRemoved(callback, ancestors?)` | Connects a listener for when a tagged instance is removed; optional ancestor filtering | `() -> ()` (disconnect function)                             |           |

---

## 📦 Installation

1. Copy the provided module script into **ReplicatedStorage** or **ServerScriptService**.
2. Require it in your code:

```lua
local Collection = require(path.to.CollectionModule)
```

3. Initialize a new collection by tag name:

```lua
local Enemies = Collection("Enemy")
```

---

## 🧱 API Reference

### **Constructor**

```lua
local collection = Collection(tagName : string)
```

Creates a new collection object tied to a specific tag.

| Parameter | Type     | Description                                     |
| --------- | -------- | ----------------------------------------------- |
| `tagName` | `string` | The name of the tag managed by this collection. |

---

### **Methods**

#### 🧾 `collection:GetTagged() -> { Instance }`

Returns all instances currently tagged with this collection’s tag.

```lua
for _, obj in pairs(Enemies:GetTagged()) do
	print(obj.Name)
end
```

---

#### ➕ `collection:AddTag(instance : Instance | {Instance})`

Adds the tag to one or multiple instances.

```lua
Enemies:AddTag(workspace.Dummy)
Enemies:AddTag({workspace.Dummy1, workspace.Dummy2})
```

---

#### ➖ `collection:RemoveTag(instance : Instance | {Instance})`

Removes the tag from one or multiple instances.

```lua
Enemies:RemoveTag(workspace.Dummy)
```

---

#### ❓ `collection:HasTag(instance : Instance | {Instance}) -> boolean`

Checks if one or more instances have the collection’s tag.

```lua
if Enemies:HasTag(workspace.Dummy) then
	print("Dummy is an enemy!")
end
```

---

#### 🟢 `collection:tagAdded(callback : (instance : Instance) -> (), ancestors : {Instance?}?) -> () -> ()`

Registers a listener for when an instance **with this tag** is added.
Optionally filter by ancestor(s). Returns a function to **disconnect** the listener.

```lua
local disconnect = Enemies:tagAdded(function(inst)
	print(inst.Name, "was tagged as Enemy!")
end, {workspace})

-- Later...
disconnect()
```

---

#### 🔴 `collection:tagRemoved(callback : (instance : Instance) -> (), ancestors : {Instance?}?) -> () -> ()`

Registers a listener for when an instance **with this tag** is removed.
Optionally filter by ancestor(s). Returns a function to **disconnect** the listener.

```lua
local disconnect = Enemies:tagRemoved(function(inst)
	print(inst.Name, "is no longer an Enemy.")
end)
```

---

## 🧩 Example Usage

```lua
local Collection = require(script.Collection)
local Collectibles = Collection("Collectible")

-- Watch for collectibles being added
Collectibles:tagAdded(function(item)
	print("New collectible:", item.Name)
end, {workspace.Items})

-- Add a tag to a part
Collectibles:AddTag(workspace.Items.Gem)

-- Remove a tag
Collectibles:RemoveTag(workspace.Items.Gem)
```

---

## 🧠 Implementation Details

* Uses **Luau strict mode** for safety
* Maintains internal listener tables to manage connection lifetimes
* Automatically disconnects `CollectionService` signals when no listeners remain
* Includes **ancestor filtering** via the internal `isAncestor()` helper

---

## ⚖️ License

MIT License © 2025
Feel free to use, modify, and distribute this module in your Roblox projects.
