package
{
   import utils.*;
   
   public class HUDPlayerListConfig
   {
      
      private static var _config:Object;
      
      public static const STATE_HIDDEN:String = "hidden";
      
      public static const STATE_SHOWN:String = "shown";
      
      public function HUDPlayerListConfig()
      {
         super();
      }
      
      public static function get() : Object
      {
         return _config;
      }
      
      public static function init(jsonObject:*) : Object
      {
         var config:* = jsonObject;
         config.x = Parser.parseNumber(config.x,0);
         config.y = Parser.parseNumber(config.y,0);
         config.anchor = Boolean(config.anchor) ? config.anchor.toLowerCase() : "top";
         config.ySpacing = Parser.parseNumber(config.ySpacing,0);
         config.width = Parser.parseNumber(config.width,250);
         config.textSize = Parser.parseNumber(config.textSize,18);
         config.textFont = Boolean(config.textFont) ? config.textFont : "$ChowderHead";
         config.textAlign = Boolean(config.textAlign) ? config.textAlign.toLowerCase() : "left";
         config.textColor = Parser.parseNumber(config.textColor,16777215);
         config.textShadow = Parser.parseBoolean(config.textShadow,true);
         config.background = Parser.parseBoolean(config.background,false);
         config.backgroundColor = Parser.parseNumber(config.backgroundColor,2236962);
         config.alpha = Parser.parseNumber(config.alpha,1);
         config.backgroundAlpha = Parser.parseNumber(config.backgroundAlpha,0.5);
         config.blendMode = Boolean(config.blendMode) ? config.blendMode.toLowerCase() : "normal";
         config.textBlendMode = Boolean(config.textBlendMode) ? config.textBlendMode.toLowerCase() : "normal";
         config.refresh = Parser.parseNumber(config.refresh,1000);
         config.format = Boolean(config.format) ? config.format : "[{level}] {name} {bounty}";
         config.sortBy = Boolean(config.sortBy) ? config.sortBy.toLowerCase() : "default";
         config.toggleVisibilityHotkey = Buttons.parseValue(config.toggleVisibilityHotkey);
         config.toggleVendorsHotkey = Buttons.parseValue(config.toggleVendorsHotkey);
         config.forceHideHotkey = Buttons.parseValue(config.forceHideHotkey);
         if(!config.formats)
         {
            config.formats = {};
            config.formats.bounty = config.formatBounty != null ? config.formatBounty : "({caps}c)";
         }
         var Keys:* = [];
         for(f in config.formats)
         {
            Keys.push(f);
         }
         config.formats.Keys = Keys;
         if(!config.vendorData)
         {
            config.vendorData = {};
            config.vendorData.enabled = false;
         }
         else if(config.vendorData.enabled)
         {
            if(!config.vendorData.format)
            {
               config.vendorData.format = [];
            }
            if(!config.vendorData.formats)
            {
               config.vendorData.formats = {};
            }
            Keys = [];
            for(f in config.vendorData.formats)
            {
               Keys.push(f);
            }
            config.vendorData.formats.Keys = Keys;
            if(!config.vendorData.hidePlayersWithoutVendorData)
            {
               config.vendorData.hidePlayersWithoutVendorData = [];
            }
         }
         if(!config.sortOrder)
         {
            config.sortOrder = [];
         }
         else
         {
            for(i in config.sortOrder)
            {
               config.sortOrder[i] = config.sortOrder[i].toLowerCase();
            }
         }
         if(!config.additionalData)
         {
            config.additionalData = [];
         }
         if(!config.additionalDataAfter)
         {
            config.additionalDataAfter = [];
         }
         if(!config.displayData)
         {
            config.displayData = config.additionalData;
            config.displayData.push("group:All");
            config.displayData = config.displayData.concat(config.additionalDataAfter);
         }
         else
         {
            if(config.additionalData.length > 0)
            {
               config.displayData = config.additionalData.concat(config.displayData);
            }
            if(config.additionalDataAfter.length > 0)
            {
               config.displayData.push("group:All");
               config.displayData = config.displayData.concat(config.additionalDataAfter);
            }
         }
         if(!config.customColors)
         {
            config.customColors = {};
         }
         else
         {
            for(color in config.customColors)
            {
               config.customColors[color] = Parser.parseNumber(config.customColors[color],config.textColor);
            }
         }
         if(!config.hideTypes)
         {
            config.hideTypes = [];
         }
         else
         {
            for(i in config.hideTypes)
            {
               config.hideTypes[i] = config.hideTypes[i].toLowerCase();
            }
         }
         if(!config.hidePlayers)
         {
            config.hidePlayers = [];
         }
         else
         {
            for(i in config.hidePlayers)
            {
               config.hidePlayers[i] = config.hidePlayers[i].toLowerCase();
            }
         }
         if(config.hideInHUDModes)
         {
            config.HUDModes = config.hideInHUDModes;
            config.HUDModesState = STATE_HIDDEN;
         }
         else if(!config.HUDModes)
         {
            config.HUDModes = [];
            config.HUDModesState = STATE_HIDDEN;
         }
         else
         {
            if(config.HUDModesState != null)
            {
               config.HUDModesState = config.HUDModesState.toLowerCase();
            }
            if(config.HUDModesState != STATE_SHOWN)
            {
               config.HUDModesState = STATE_HIDDEN;
            }
         }
         _config = config;
         return _config;
      }
   }
}

