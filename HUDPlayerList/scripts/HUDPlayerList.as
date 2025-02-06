package
{
   import Shared.*;
   import Shared.AS3.*;
   import Shared.AS3.Data.*;
   import Shared.AS3.Events.*;
   import com.adobe.serialization.json.*;
   import fl.motion.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import scaleform.gfx.*;
   import utils.*;
   
   public class HUDPlayerList extends MovieClip
   {
      
      public static const MOD_NAME:String = "HUDPlayerList";
      
      public static const MOD_VERSION:String = "1.1.6";
      
      public static const FULL_MOD_NAME:String = MOD_NAME + " " + MOD_VERSION;
      
      public static const CONFIG_FILE:String = "../HUDPlayerList.json";
      
      public static const CONFIG_RELOAD_TIME:uint = 10050;
      
      private static const DATA_SEPARATOR:String = "separator";
      
      private static const DATA_EMPTY_SPACE:String = "emptyspace";
      
      private static const DATA_TEXT:String = "text";
      
      private static const DATA_GROUP:String = "group";
      
      private static const IS_FRIEND:String = "isFriend";
      
      private static const IS_HIDDEN:String = "isHidden";
      
      private static const IS_SERVER_FULL:String = "isServerFull";
      
      private static const IS_TEXTCHAT_USER:String = "isTextChatUser";
      
      private static const PLAYER_WANTED:String = "MostWanted";
      
      private static const PLAYER_REMOTE:String = "PlayerRemote";
      
      private static const PLAYER_LOCAL:String = "PlayerLocal";
      
      private static const PLAYER_TEAM_LEADER:String = "TeamLeader";
      
      private static const PLAYER_TEAM_MEMBER:String = "TeamMember";
      
      private static const CAMP_MARKER:String = "YourCampMarker";
      
      private static const MAX_PLAYERS_PRIVATE:uint = 8;
      
      private static const MAX_PLAYERS_PUBLIC:uint = 24;
      
      private static const SORT_BY_CUSTOM:String = "custom";
      
      private static const SORT_BY_PROPERTY:String = "property";
      
      private static const SORT_BY_LEVEL:String = "level";
      
      private static const SORT_BY_BOUNTY:String = "bounty";
      
      private static const STRING_NAME:String = "{name}";
      
      private static const STRING_TYPE:String = "{type}";
      
      private static const STRING_LEVEL:String = "{level}";
      
      private static const STRING_BOUNTY:String = "{bounty}";
      
      private static const STRING_CAPS:String = "{caps}";
      
      private static const STRING_VALUE:String = "{value}";
      
      private static const STRING_CHARACTER_NAME:String = "{characterName}";
      
      private static const STRING_ANGLE:String = "{angle}";
      
      private static const STRING_ANGLE_COMPASS:String = "{angleCompass}";
      
      private static const STRING_DISTANCE:String = "{distance}";
      
      private static const STRING_DIRECTION:String = "{direction}";
      
      private static const STRINGS_COORDINATES:* = [STRING_ANGLE,STRING_ANGLE_COMPASS,STRING_DISTANCE,STRING_DIRECTION];
      
      private static const TITLE_HUDMENU:String = "HUDMenu";
      
      private static const TITLE_TEXTCHAT:String = "TextChat";
      
      private static const TITLE_LOADER:String = "flash.display::Loader";
      
      private static const TITLE_DELIMITED:String = "|";
      
      private static const MAIN_MENU:String = "MainMenu";
      
      private static const VENDING_CATEGORIES:* = {
         "{APPAREL}":0,
         "{ARMOR0}":1,
         "{ARMOR1}":2,
         "{ARMOR2}":3,
         "{ARMOR3}":4,
         "{WEAPON0}":5,
         "{WEAPON1}":6,
         "{WEAPON2}":7,
         "{WEAPON3}":8,
         "{MODS}":9,
         "{STIMPAK}":10,
         "{MEDS}":11,
         "{FOOD}":12,
         "{DRINK}":13,
         "{AMMO}":14,
         "{EXPLOSIVE}":15,
         "{JUNK}":16,
         "{PLAN}":17,
         "{MISC}":18
      };
      
      private static const RAD2DEG:Number = 180 / Math.PI;
      
      private static const MAP_DISTANCE_CONST:Number = 1 / 4096;
      
      private static const LOCALIZED_HEADINGS:* = ["$Compass_West","$Compass_North","$Compass_East","$Compass_South"];
      
      private static var HEADINGS:* = [];
       
      
      private var _lastConfigUpdateTime:Number = 0;
      
      private var _lastRenderTime:Number = 0;
      
      private var topLevel:* = null;
      
      private var dummy_tf:TextField;
      
      private var timer:Timer;
      
      private var configTimer:Timer;
      
      private var displayTimer:Timer;
      
      private var lastConfig:String;
      
      private var HUDModeData:*;
      
      private var AccountInfoData:*;
      
      private var CharacterInfoData:*;
      
      private var PublicTeamsData:*;
      
      private var MapMenuData:*;
      
      private var vendorData:*;
      
      private var campMarkers:*;
      
      private var playerPosition:*;
      
      private var visitedCamps:*;
      
      private var _players:Array;
      
      private var _playerCount:int;
      
      private var _textChatUsers:Array;
      
      private var players_tf:Array;
      
      private var players_index:int = 0;
      
      private var textFormat:TextFormat;
      
      private var yOffset:Number = 0;
      
      private var separators:Array;
      
      private var maxServerPlayers:uint = 0;
      
      private var textChat:*;
      
      private var isHudMenu:Boolean = true;
      
      private var isInMainMenu:Boolean = true;
      
      private var toggleVisibility:Boolean = false;
      
      public function HUDPlayerList()
      {
         this.visitedCamps = {};
         this.campMarkers = {};
         this.vendorData = {};
         this.players_tf = [];
         this.separators = [];
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         this.HUDModeData = BSUIDataManager.GetDataFromClient("HUDModeData");
         this.AccountInfoData = BSUIDataManager.GetDataFromClient("AccountInfoData");
         this.PublicTeamsData = BSUIDataManager.GetDataFromClient("PublicTeamsData");
         this.MapMenuData = BSUIDataManager.GetDataFromClient("MapMenuData");
         this.configTimer = new Timer(CONFIG_RELOAD_TIME);
         this.configTimer.addEventListener(TimerEvent.TIMER,this.loadConfig);
         this.configTimer.start();
      }
      
      public static function toString(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function ShowHUDMessage(param1:String) : void
      {
         GlobalFunc.ShowHUDMessage("[" + FULL_MOD_NAME + "] " + param1);
      }
      
      private static function getDirection(y:Number, x:Number) : String
      {
         var angle:* = Math.atan2(y,x);
         return getDirection(angle);
      }
      
      private static function getDirection(atan2angle:Number) : String
      {
         if(HEADINGS.length == 0)
         {
            return "";
         }
         var angle:* = atan2angle;
         var increment:* = 2 * Math.PI / HEADINGS.length;
         var testangle:* = -Math.PI + increment / 2;
         var i:int = 0;
         while(angle > testangle)
         {
            i++;
            if(i > HEADINGS.length - 1)
            {
               break;
            }
            testangle += increment;
         }
         return HEADINGS[i % HEADINGS.length];
      }
      
      private static function getDistance(x:Number, y:Number) : Number
      {
         return Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
      }
      
      public function addedToStageHandler(param1:Event) : *
      {
         this.topLevel = stage.getChildAt(0);
         if(Boolean(this.topLevel))
         {
            if(getQualifiedClassName(this.topLevel) == TITLE_HUDMENU)
            {
               this.isInMainMenu = false;
            }
            else
            {
               this.isHudMenu = false;
               BSUIDataManager.Subscribe("MenuStackData",this.updateIsMainMenu);
            }
            BSUIDataManager.Subscribe("RecentActivitiesData",this.onRecentActivitiesDataUpdate);
            trace(MOD_NAME + " added to stage: " + getQualifiedClassName(this.topLevel));
         }
         else
         {
            trace(MOD_NAME + " not added to stage: " + getQualifiedClassName(this.topLevel));
            ShowHUDMessage("Not added to stage: " + getQualifiedClassName(this.topLevel));
         }
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
      }
      
      public function keyDownHandler(event:Event) : void
      {
         if(!config || !players_tf)
         {
            return;
         }
         if(config.debugKeys)
         {
            displayMessage("keyDown: " + event.keyCode);
         }
         if(event.keyCode == config.toggleVisibilityHotkey)
         {
            this.toggleVisibility = !this.toggleVisibility;
         }
      }
      
      private function updateIsMainMenu(event:FromClientDataEvent) : void
      {
         this.isInMainMenu = event.data && event.data.menuStackA && event.data.menuStackA.some(function(x:*):*
         {
            return x.menuName == MAIN_MENU;
         });
      }
      
      private function onRecentActivitiesDataUpdate(event:FromClientDataEvent) : void
      {
         var vendors:* = {};
         var i:int = 0;
         while(i < event.data.recentActivities.length)
         {
            if(event.data.recentActivities[i].type == 3)
            {
               vendors[event.data.recentActivities[i].mapMarkerId] = event.data.recentActivities[i].vendingCategoryCounts;
            }
            i++;
         }
         this.vendorData = vendors;
      }
      
      public function loadConfig() : void
      {
         var loaderComplete:Function;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            if(config && Boolean(config.disableRealTimeEdit))
            {
               return;
            }
            loaderComplete = function(param1:Event):void
            {
               var jsonData:Object;
               try
               {
                  if(lastConfig != loader.data)
                  {
                     jsonData = new JSONDecoder(loader.data,true).getValue();
                     HUDPlayerListConfig.init(jsonData);
                     initTextField();
                     initTimers();
                     _lastConfigUpdateTime = getTimer();
                     lastConfig = loader.data;
                  }
               }
               catch(e:Error)
               {
                  ShowHUDMessage("Error loading config: " + e);
               }
            };
            url = new URLRequest(CONFIG_FILE);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete);
         }
         catch(e:Error)
         {
            ShowHUDMessage("Error loading config: " + e);
         }
      }
      
      private function initTextField() : void
      {
         this.dummy_tf = new TextField();
         var i:int = 0;
         var headings:* = [];
         while(i < 4)
         {
            GlobalFunc.SetText(this.dummy_tf,LOCALIZED_HEADINGS[i]);
            headings.push(this.dummy_tf.text);
            i++;
         }
         HEADINGS = [headings[0],headings[0] + headings[1] + headings[0],headings[1] + headings[0],headings[1] + headings[1] + headings[0],headings[1],headings[1] + headings[1] + headings[2],headings[1] + headings[2],headings[2] + headings[1] + headings[2],headings[2],headings[2] + headings[3] + headings[2],headings[3] + headings[2],headings[3] + headings[3] + headings[2],headings[3],headings[3] + headings[3] + headings[0],headings[3] + headings[0],headings[0] + headings[3] + headings[0]];
         GlobalFunc.SetText(this.dummy_tf,"");
         this.formatMessage();
      }
      
      private function initTimers() : void
      {
         if(this.displayTimer)
         {
            this.displayTimer.removeEventListener(TimerEvent.TIMER,this.displayPlayerList);
         }
         this.displayTimer = new Timer(config.refresh);
         this.displayTimer.addEventListener(TimerEvent.TIMER,this.displayPlayerList);
         this.displayTimer.start();
      }
      
      public function get config() : Object
      {
         return HUDPlayerListConfig.get();
      }
      
      public function get elapsedTime() : Number
      {
         return getTimer() / 1000;
      }
      
      public function get timeSinceLastConfigUpdate() : Number
      {
         return (getTimer() - this._lastConfigUpdateTime) / 1000;
      }
      
      public function formatMessage() : void
      {
         this.dummy_tf.htmlText = MOD_VERSION;
         this.dummy_tf.x = config.x;
         this.dummy_tf.y = config.y;
         this.dummy_tf.width = config.width;
         this.dummy_tf.background = false;
         TextFieldEx.setTextAutoSize(this.dummy_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         this.dummy_tf.autoSize = TextFieldAutoSize.LEFT;
         this.dummy_tf.wordWrap = false;
         this.dummy_tf.multiline = true;
         this.dummy_tf.visible = true;
         this.textFormat = new TextFormat(config.textFont,config.textSize,config.textColor);
         this.textFormat.align = config.textAlign;
         this.dummy_tf.defaultTextFormat = this.textFormat;
         this.dummy_tf.setTextFormat(this.textFormat);
         this.dummy_tf.filters = [new DropShadowFilter(2,45,0,1,1,1,1,BitmapFilterQuality.HIGH)];
         this.alpha = config.alpha;
         this.blendMode = config.blendMode;
      }
      
      public function resetMessages() : void
      {
         this.separators = [];
         this.graphics.clear();
         this.players_index = 0;
         this.yOffset = 0;
         for(p in players_tf)
         {
            if(players_tf[p] != null)
            {
               players_tf[p].visible = false;
               players_tf[p].defaultTextFormat = this.textFormat;
               players_tf[p].setTextFormat(this.textFormat);
            }
         }
      }
      
      public function createTextfield() : TextField
      {
         tf = new TextField();
         tf.multiline = false;
         tf.wordWrap = false;
         tf.defaultTextFormat = this.textFormat;
         TextFieldEx.setTextAutoSize(tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         tf.setTextFormat(this.textFormat);
         addChild(tf);
         return tf;
      }
      
      public function applyConfig(tf:TextField) : void
      {
         tf.visible = true;
         tf.x = config.x;
         tf.background = false;
         tf.width = config.width;
         tf.height = this.dummy_tf.height;
         if(players_index == 0)
         {
            tf.y = config.y;
         }
         else
         {
            tf.y = LastDisplayPlayer.y + LastDisplayPlayer.height + config.ySpacing + yOffset;
            yOffset = 0;
         }
         tf.blendMode = config.textBlendMode;
         tf.filters = Boolean(config.textShadow) ? this.dummy_tf.filters : [];
      }
      
      public function displayMessage(text:String) : void
      {
         if(players_tf.length < players_index || players_tf[players_index] == null)
         {
            players_tf[players_index] = createTextfield();
         }
         applyConfig(players_tf[players_index]);
         players_tf[players_index].text = text;
         players_index++;
      }
      
      public function drawBackground() : void
      {
         if(config.background)
         {
            this.graphics.beginFill(config.backgroundColor,config.backgroundAlpha);
            this.graphics.drawRect(config.x,config.y,config.width,LastDisplayPlayer.y + LastDisplayPlayer.height - config.y);
            this.graphics.endFill();
         }
         if(config.anchor == "bottom")
         {
            this.y = -(LastDisplayPlayer.y + LastDisplayPlayer.height - config.y);
         }
         else if(this.y != 0)
         {
            this.y = 0;
         }
      }
      
      public function get LastDisplayPlayer() : TextField
      {
         if(players_index == 0)
         {
            return players_tf[players_index];
         }
         return players_tf[players_index - 1];
      }
      
      public function customSort(objA:Object, objB:Object) : int
      {
         var indexA:int = int.MAX_VALUE;
         var indexB:int = int.MAX_VALUE;
         var textA:String = (objA.name + objA.type + (Boolean(objA.isFriend) ? IS_FRIEND : "") + (Boolean(objA.isTextChatUser) ? IS_TEXTCHAT_USER : "")).toLowerCase();
         var textB:String = (objB.name + objB.type + (Boolean(objB.isFriend) ? IS_FRIEND : "") + (Boolean(objB.isTextChatUser) ? IS_TEXTCHAT_USER : "")).toLowerCase();
         config.sortOrder.forEach(function(phrase:String, index:int, array:Array):void
         {
            if(textA.indexOf(phrase) != -1 && index < indexA)
            {
               indexA = index;
            }
            if(textB.indexOf(phrase) != -1 && index < indexB)
            {
               indexB = index;
            }
         });
         if(indexA < indexB)
         {
            return -1;
         }
         if(indexA > indexB)
         {
            return 1;
         }
         return textA.localeCompare(textB);
      }
      
      public function getCustomColor(name:String) : Number
      {
         if(config.customColors[name] != null)
         {
            return config.customColors[name];
         }
         return config.textColor;
      }
      
      public function applyColor(name:String) : Boolean
      {
         if(config.customColors[name] != null)
         {
            LastDisplayPlayer.textColor = config.customColors[name];
            return true;
         }
         return false;
      }
      
      public function addSeparator(data:String) : void
      {
         if(data == null || data.length == 0)
         {
            return;
         }
         data = data.replace(" ","");
         var parts:Array = data.split(":");
         var color:Number = Number(config.textColor);
         if(parts.length > 1)
         {
            var height:Number = Parser.parseNumber(parts[1],0);
            if(parts.length > 2)
            {
               color = Parser.parseNumber(parts[2],getCustomColor(parts[2]));
            }
            if(players_index == 0)
            {
               var y:Number = Number(config.y);
            }
            else
            {
               y = LastDisplayPlayer.y + LastDisplayPlayer.height + config.ySpacing / 2 + yOffset;
            }
            yOffset += height;
            separators.push({
               "y":y,
               "height":height,
               "color":color
            });
         }
      }
      
      public function addEmptySpace(data:String) : void
      {
         if(data == null || data.length == 0)
         {
            return;
         }
         var parts:Array = data.split(":");
         var space:Number = Parser.parseNumber(parts[1],0);
         yOffset += space;
      }
      
      public function addCustomText(data:String) : void
      {
         if(data == null || data.length == 0)
         {
            return;
         }
         data = data.replace("/:","/COLON/");
         var parts:Array = data.split(":");
         if(parts.length == 3)
         {
            var color:Number = Parser.parseNumber(parts[1],getCustomColor(parts[1]));
            var text:String = parts[2];
            text = text.replace("/COLON/",":");
            displayMessage(text);
            LastDisplayPlayer.textColor = color;
         }
      }
      
      public function displayGroup(groupName:*) : void
      {
         filteredPlayers = _players.filter(function(player:Object):Boolean
         {
            switch(groupName)
            {
               case PLAYER_REMOTE:
               case PLAYER_LOCAL:
               case PLAYER_TEAM_LEADER:
               case PLAYER_TEAM_MEMBER:
               case PLAYER_WANTED:
               case IS_HIDDEN:
                  return groupName == player.type;
               case IS_FRIEND:
               case IS_TEXTCHAT_USER:
                  return player[groupName];
               default:
                  return true;
            }
         });
         for each(fp in filteredPlayers)
         {
            _players.splice(_players.indexOf(fp),1);
         }
         filteredPlayers = sortPlayers(filteredPlayers);
         displayPlayers(filteredPlayers);
      }
      
      public function drawSeparators() : void
      {
         for(s in separators)
         {
            this.graphics.beginFill(separators[s].color);
            this.graphics.drawRect(config.x,separators[s].y,config.width,separators[s].height);
            this.graphics.endFill();
         }
      }
      
      public function formatPlayer(player:Object) : String
      {
         var textToDisplay:String = config.format;
         for(f in config.formats)
         {
            switch(f)
            {
               case SORT_BY_BOUNTY:
                  if(player.type == PLAYER_WANTED)
                  {
                     textToDisplay = textToDisplay.replace(STRING_BOUNTY,config.formats[f]).replace(STRING_CAPS,player.bounty);
                  }
                  else
                  {
                     textToDisplay = textToDisplay.replace(STRING_BOUNTY,"");
                  }
                  break;
               case PLAYER_REMOTE:
               case PLAYER_LOCAL:
               case PLAYER_TEAM_LEADER:
               case PLAYER_TEAM_MEMBER:
               case PLAYER_WANTED:
               case IS_HIDDEN:
                  if(player.type == f)
                  {
                     textToDisplay = textToDisplay.replace("{" + f + "}",config.formats[f]);
                  }
                  else
                  {
                     textToDisplay = textToDisplay.replace("{" + f + "}","");
                  }
                  break;
               case IS_FRIEND:
               case IS_TEXTCHAT_USER:
                  if(player[f])
                  {
                     textToDisplay = textToDisplay.replace("{" + f + "}",config.formats[f]);
                  }
                  else
                  {
                     textToDisplay = textToDisplay.replace("{" + f + "}","");
                  }
                  break;
            }
         }
         return textToDisplay;
      }
      
      public function sortPlayers(players:Array) : Array
      {
         switch(config.sortBy)
         {
            case SORT_BY_CUSTOM:
               players.sort(customSort);
               break;
            case SORT_BY_PROPERTY:
               var sortOptions:Array = new Array(config.sortOrder.length);
               for(p in config.sortOrder)
               {
                  if(config.sortOrder[p] == SORT_BY_LEVEL || config.sortOrder[p] == SORT_BY_BOUNTY)
                  {
                     sortOptions[p] = Array.NUMERIC | Array.DESCENDING;
                  }
                  else
                  {
                     sortOptions[p] = Array.CASEINSENSITIVE;
                  }
               }
               players = players.sortOn(config.sortOrder,sortOptions);
         }
         if(config.reverseSort)
         {
            players.reverse();
         }
         return players;
      }
      
      public function displayPlayers(players:Array) : void
      {
         for each(player in players)
         {
            if(this.isValidPlayerToShow(player))
            {
               var textToDisplay:String = this.formatPlayer(player);
               textToDisplay = textToDisplay.replace(STRING_NAME,player.name).replace(STRING_TYPE,player.type).replace(STRING_LEVEL,player.level);
               if(player.type == PLAYER_LOCAL)
               {
                  textToDisplay = textToDisplay.replace(STRING_CHARACTER_NAME,this.CharacterInfoData.data.name);
               }
               else
               {
                  textToDisplay = textToDisplay.replace(STRING_CHARACTER_NAME,"");
               }
               displayMessage(textToDisplay);
               var colorApplied:Boolean = false;
               if(player.type == PLAYER_WANTED)
               {
                  colorApplied = applyColor(PLAYER_WANTED);
               }
               if(!colorApplied && player[IS_FRIEND])
               {
                  colorApplied = applyColor(IS_FRIEND);
               }
               if(!colorApplied && player[IS_TEXTCHAT_USER])
               {
                  colorApplied = applyColor(IS_TEXTCHAT_USER);
               }
               if(!colorApplied)
               {
                  applyColor(player.type);
               }
               if(config.vendorData.enabled)
               {
                  var marker:* = campMarkers[player.name];
                  if(marker != null && vendorData[marker.markerId] != null && vendorData[marker.markerId].length > 0)
                  {
                     var yDiff:Number = marker.y - playerPosition.y;
                     var xDiff:Number = marker.x - playerPosition.x;
                     var distance:int = int(getDistance(xDiff,yDiff) / MAP_DISTANCE_CONST);
                     if(distance < 20)
                     {
                        visitedCamps[player.name] = true;
                     }
                     if(!(config.vendorData.hideVisitedCamps && visitedCamps[player.name]))
                     {
                        var angle:* = Math.atan2(yDiff,xDiff);
                        var direction:* = getDirection(angle);
                        var iangle:int = (360 - angle * RAD2DEG) % 360;
                        var iangleCompass:int = (450 + angle * RAD2DEG) % 360;
                        var i:int = 0;
                        if(visitedCamps[player.name] && config.customColors["visitedCamp"] != null)
                        {
                           var color:Number = Number(config.customColors["visitedCamp"]);
                        }
                        else if(Boolean(config.vendorData.usePlayerColor))
                        {
                           color = LastDisplayPlayer.textColor;
                        }
                        else
                        {
                           color = getCustomColor("vendorData");
                        }
                        while(i < config.vendorData.format.length)
                        {
                           var vdata:* = formatVendingData(config.vendorData.format[i],vendorData[marker.markerId]);
                           if(vdata != "")
                           {
                              vdata = vdata.replace(STRING_ANGLE,iangle).replace(STRING_ANGLE_COMPASS,iangleCompass).replace(STRING_DIRECTION,direction).replace(STRING_DISTANCE,distance);
                              displayMessage(vdata);
                              LastDisplayPlayer.textColor = color;
                           }
                           i++;
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function formatVendingData(format:String, vendorData:Array) : String
      {
         if(format == null || format.length == 0)
         {
            return "";
         }
         var textToDisplay:String = format;
         var hasData:Boolean = false;
         for(cat in VENDING_CATEGORIES)
         {
            if(textToDisplay.indexOf(cat) != -1)
            {
               if(vendorData.length > VENDING_CATEGORIES[cat] && vendorData[VENDING_CATEGORIES[cat]] != 0 && config.vendorData.formats[cat] != null)
               {
                  textToDisplay = textToDisplay.replace(cat,config.vendorData.formats[cat].replace(STRING_VALUE,vendorData[VENDING_CATEGORIES[cat]]));
                  hasData = true;
               }
               else
               {
                  textToDisplay = textToDisplay.replace(cat,"");
               }
            }
         }
         return hasData ? textToDisplay : "";
      }
      
      public function displayPlayerList() : void
      {
         var t1:Number;
         var t2:*;
         var dataField:String;
         var parts:Array;
         try
         {
            t1 = Number(getTimer());
            this.visible = this.isValidHUDMode() ^ this.toggleVisibility;
            if(!this.visible)
            {
               return;
            }
            this.resetMessages();
            _players = this.getPlayers();
            if(maxServerPlayers == 0)
            {
               maxServerPlayers = Boolean(this.AccountInfoData.data.isOnPrivateWorld) ? MAX_PLAYERS_PRIVATE : MAX_PLAYERS_PUBLIC;
            }
            if(config.displayData && config.displayData.length > 0)
            {
               for(d in config.displayData)
               {
                  dataField = config.displayData[d];
                  parts = dataField.split(":");
                  switch(parts[0])
                  {
                     case "debug":
                        displayMessage("HUDModeData: " + this.HUDModeData.data);
                        displayMessage("AccountInfoData: " + this.AccountInfoData.data);
                        displayMessage("PublicTeamsData: " + this.PublicTeamsData.data);
                        displayMessage("MapMenuData: " + this.MapMenuData.data);
                        displayMessage("campMarkers");
                        for(m in this.campMarkers)
                        {
                           displayMessage(m + ":" + this.campMarkers[m]);
                        }
                        displayMessage("vendorData");
                        for(v in this.vendorData)
                        {
                           displayMessage(v + ":" + this.vendorData[v]);
                        }
                        displayMessage("----------");
                        break;
                     case "showVersion":
                        displayMessage(FULL_MOD_NAME + (this.isHudMenu ? "" : " (non-HUD)"));
                        applyColor(dataField);
                        break;
                     case "showLastConfigUpdate":
                        displayMessage("ConfigUpdate: " + GlobalFunc.FormatTimeString(this.timeSinceLastConfigUpdate) + " ago");
                        applyColor(dataField);
                        break;
                     case "showElapsedTime":
                        displayMessage("ElapsedTime: " + GlobalFunc.FormatTimeString(this.elapsedTime));
                        applyColor(dataField);
                        break;
                     case "showHUDMode":
                        displayMessage("HUDMode: " + (!this.isInMainMenu ? this.HUDModeData.data.hudMode : MAIN_MENU));
                        applyColor(dataField);
                        break;
                     case "showPlayerCount":
                        displayMessage("Players: " + _playerCount + "/" + maxServerPlayers);
                        applyColor(_playerCount >= maxServerPlayers ? IS_SERVER_FULL : dataField);
                        break;
                     case "showRenderTime":
                        displayMessage("RenderTime: " + this._lastRenderTime + "ms");
                        applyColor(dataField);
                        break;
                     case DATA_SEPARATOR:
                        addSeparator(dataField);
                        break;
                     case DATA_EMPTY_SPACE:
                        addEmptySpace(dataField);
                        break;
                     case DATA_TEXT:
                        addCustomText(dataField);
                        break;
                     case DATA_GROUP:
                        if(parts.length > 1)
                        {
                           displayGroup(parts[1]);
                        }
                        break;
                  }
               }
            }
            drawBackground();
            drawSeparators();
            this._lastRenderTime = getTimer() - t1;
         }
         catch(error:Error)
         {
            displayMessage("Error displaying players: " + error);
            drawBackground();
         }
      }
      
      public function getPlayers() : Array
      {
         if(!this.CharacterInfoData)
         {
            this.CharacterInfoData = BSUIDataManager.GetDataFromClient("CharacterInfoData");
         }
         if(!this.AccountInfoData.data || !this.CharacterInfoData.data)
         {
            return;
         }
         this._textChatUsers = this.getTextChatUserList();
         var players:Array = [];
         var playerName:String = "";
         var _campMarkers:* = {};
         if(this.MapMenuData && this.MapMenuData.data && this.MapMenuData.data.MarkerData)
         {
            for each(marker in this.MapMenuData.data.MarkerData)
            {
               switch(marker.markerType)
               {
                  case PLAYER_LOCAL:
                     players.push({
                        "name":this.AccountInfoData.data.name,
                        "type":marker.markerType,
                        "level":this.CharacterInfoData.data.level,
                        "bounty":this.CharacterInfoData.data.bounty
                     });
                     playerPosition = {
                        "x":marker.x,
                        "y":marker.y
                     };
                     break;
                  case PLAYER_REMOTE:
                  case PLAYER_TEAM_MEMBER:
                  case PLAYER_TEAM_LEADER:
                  case PLAYER_WANTED:
                  case "PlayerRemote_Friend":
                  case "PlayerRemote_PVP":
                  case "BabylonSpawnMarkerPlayer":
                  case "BabylonSpawnMarkerTeam":
                     playerName = marker.text.split(TITLE_DELIMITED)[0];
                     players.push({
                        "name":playerName,
                        "type":marker.markerType,
                        "level":marker.playerLevel,
                        "bounty":marker.bounty,
                        "isFriend":marker.isFriend,
                        "isTextChatUser":(playerName.length > 0 ? isTextChatUser(playerName) : false)
                     });
                     break;
                  case CAMP_MARKER:
                     if(marker.isVending)
                     {
                        _campMarkers[marker.owningPlayerName.split(TITLE_DELIMITED)[0]] = {
                           "markerId":marker.markerID,
                           "x":marker.x,
                           "y":marker.y
                        };
                     }
                     break;
               }
            }
         }
         this.campMarkers = _campMarkers;
         if(this.PublicTeamsData && this.PublicTeamsData.data && this.PublicTeamsData.data.publicTeams)
         {
            for each(team in this.PublicTeamsData.data.publicTeams)
            {
               for each(member in team.members)
               {
                  if(member.playerName.length > 0)
                  {
                     var exists:Boolean = false;
                     for each(player in players)
                     {
                        if(player.name == member.playerName)
                        {
                           if(!member.isLocalPlayerTeammate && (player.type == PLAYER_TEAM_LEADER || player.type == PLAYER_TEAM_MEMBER))
                           {
                              player.type = PLAYER_REMOTE;
                           }
                           exists = true;
                           break;
                        }
                     }
                     if(!exists)
                     {
                        players.push({
                           "name":member.playerName,
                           "type":IS_HIDDEN,
                           "level":member.playerLvl,
                           "bounty":0,
                           "isTextChatUser":(member.playerName.length > 0 ? isTextChatUser(member.playerName) : false)
                        });
                     }
                  }
               }
            }
         }
         _playerCount = players.length;
         return players;
      }
      
      public function isTextChatUser(name:String) : Boolean
      {
         if(name == this.AccountInfoData.data.name || !this._textChatUsers)
         {
            return false;
         }
         return this._textChatUsers.indexOf(name) != -1;
      }
      
      public function isValidPlayerToShow(player:Object) : Boolean
      {
         if(!player)
         {
            return false;
         }
         var indexType:int = int(ArrayUtils.indexOfCaseInsensitiveString(config.hideTypes,player.type));
         if(indexType != -1)
         {
            return false;
         }
         var index:int = int(ArrayUtils.indexOfCaseInsensitiveString(config.hidePlayers,player.name));
         return index == -1;
      }
      
      public function getTextChat() : void
      {
         if(!this.isHudMenu || !this.topLevel)
         {
            return;
         }
         var i:int = this.topLevel.numChildren - 1;
         while(i >= 0)
         {
            if(getQualifiedClassName(this.topLevel.getChildAt(i)) == TITLE_LOADER)
            {
               if(getQualifiedClassName(this.topLevel.getChildAt(i).content) == TITLE_TEXTCHAT)
               {
                  this.textChat = this.topLevel.getChildAt(i).content;
                  break;
               }
            }
            i--;
         }
      }
      
      public function getTextChatUserList() : Array
      {
         if(!this.textChat)
         {
            this.getTextChat();
         }
         if(this.textChat && this.textChat.TextChatBase_mc && this.textChat.TextChatBase_mc.UserList_mc && this.textChat.TextChatBase_mc.UserList_mc.UserList && this.textChat.TextChatBase_mc.UserList_mc.UserList.UserListArray)
         {
            return this.textChat.TextChatBase_mc.UserList_mc.UserList.UserListArray;
         }
         return [];
      }
      
      public function isValidHUDMode() : Boolean
      {
         if(config)
         {
            if(config.HUDModesState == HUDPlayerListConfig.STATE_HIDDEN)
            {
               return this.isInMainMenu ? config.HUDModes.indexOf(MAIN_MENU) == -1 : config.HUDModes.indexOf(this.HUDModeData.data.hudMode) == -1;
            }
            return this.isInMainMenu ? config.HUDModes.indexOf(MAIN_MENU) != -1 : config.HUDModes.indexOf(this.HUDModeData.data.hudMode) != -1;
         }
         return true;
      }
   }
}
