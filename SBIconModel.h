/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: (null)
 */

#import <Foundation/NSObject.h>

@class NSMutableSet, NSMutableDictionary, SBRootFolder, SBNewsstandIcon, NSSet, NSDictionary;

@interface SBIconModel : NSObject {
	NSDictionary* _lastKnownUserGeneratedIconState;
	NSSet* _lastKnownUserGeneratedIconStateFlattened;
	NSMutableDictionary* _leafIconsByIdentifier;
	NSSet* _hiddenIconTags;
	NSSet* _visibleIconTags;
	BOOL _tagsHaveBeenSet;
	NSMutableSet* _downloadedIconIDs;
	SBRootFolder* _rootFolder;
	SBNewsstandIcon* _newsstandIcon;
	BOOL _needsRelayout;
	BOOL _allowReadingCachedStateFromDisk;
}
+(id)sharedInstance;
+(id)_migrateLeafIdentifierIfNecessary:(id)necessary;
+(id)_modernIconCellForCell:(id)cell;
+(id)_modernIconListForList:(id)list;
+(id)_modernIconListsForLists:(id)lists;
+(id)modernIconStateForState:(id)state;
-(id)init;
-(void)dealloc;
-(id)rootFolder;
-(id)newsstandIcon;
-(id)newsstandFolder;
-(void)localeChanged;
-(void)setVisibilityOfIconsWithVisibleTags:(id)visibleTags hiddenTags:(id)tags;
-(BOOL)isIconVisible:(id)visible;
-(id)addDownloadingIconForDownload:(id)download;
-(id)addDownloadingIconForIdentifier:(id)identifier;
-(void)removeApplicationIconForDownloadingIcon:(id)downloadingIcon;
-(id)downloadingIconForIdentifier:(id)identifier;
-(id)addBookmarkIconForWebClip:(id)webClip;
-(void)addIconForApplication:(id)application;
-(void)addNewsstandIcon;
-(void)loadAllIcons;
-(id)visibleIconIdentifiers;
-(id)leafIcons;
-(id)_applicationIcons;
-(id)leafIconForIdentifier:(id)identifier;
-(id)applicationIconForDisplayIdentifier:(id)displayIdentifier;
-(id)iconState;
-(id)iconStatePath;
-(id)_cachedIconStatePath;
-(id)_iconState:(BOOL)state;
-(void)noteIconStateChangedExternally;
-(id)firstPageLeafIdentifiers;
-(void)_createIconLists;
-(void)uninstallBookmarkIcon:(id)icon;
-(void)addIcon:(id)icon;
-(void)removeIcon:(id)icon;
-(void)removeIconForIdentifier:(id)identifier;
-(id)indexPathForIconInPlatformState:(id)platformState;
-(id)_indexPathForIdentifier:(id)identifier inListRepresentation:(id)listRepresentation;
-(id)_indexPathForIdentifier:(id)identifier inListsRepresentation:(id)listsRepresentation;
-(BOOL)hasCachedUserGeneratedIconState;
-(void)clearCachedUserGeneratedIconState;
-(void)clearCachedUserGeneratedIconStateIfPossible;
-(id)_indexPathForFirstFreeNewsstandSlot;
-(id)indexPathForNewIcon:(id)newIcon isDesignatedLocation:(BOOL*)location replaceExistingIconAtIndexPath:(id*)indexPath;
-(void)_addNewIconToDesignatedLocation:(id)designatedLocation;
-(void)deleteIconState;
-(BOOL)_writeIconState:(id)state toPath:(id)path;
-(BOOL)_writeIconState:(id)state toPath:(id)path withFormat:(unsigned)format;
-(void)_writeCurrentIconStateWithNotification:(BOOL)notification;
-(void)_writeCachedIconState;
-(void)saveIconState;
-(void)_replaceAppIconsWithDownloadingIcons;
-(void)_replaceAppIconsWithDownloadingIcons:(id)downloadingIcons;
-(void)_flattenIconListState:(id)state intoArray:(id)array;
-(id)newsstandFolderFromIconState:(id)iconState;
-(id)_newsstandIconIdentifiersFromIconState:(id)iconState;
-(id)_flattenIconState:(id)state;
-(void)noteFolderStoppedAnimating;
-(void)noteDownloadsEnded;
-(void)noteDownloadCompletedForIconID:(id)iconID;
-(void)removeDownloadedIconID:(id)anId;
-(id)downloadedIconIDs;
-(void)relayout;
-(void)uninstallApplicationIcon:(id)icon;
-(id)forecastedLayoutForIconState:(id)iconState;
-(void)_addNodeToRootLists:(id)rootLists node:(id)node createListIfNecessary:(BOOL)necessary;
-(id)_trimList:(id)list toMaxSize:(int)maxSize;
-(id)_deepCopyIconState:(id)state;
-(id)_deepCopyListForIconState:(id)iconState;
-(id)exportState:(BOOL)state;
-(id)exportPendingState:(BOOL)state;
-(id)exportFlattenedState:(BOOL)state;
-(id)_iTunesIconListsForLists:(id)lists preApex:(BOOL)apex forPending:(BOOL)pending;
-(id)_iTunesIconListForList:(id)list preApex:(BOOL)apex forPending:(BOOL)pending;
-(id)_iTunesIconCellForCell:(id)cell preApex:(BOOL)apex forPending:(BOOL)pending;
-(id)_iTunesDictionaryForLeafIdentifier:(id)leafIdentifier;
-(id)_iTunesDictionaryForLeafIcon:(id)leafIcon;
-(id)_iTunesDictionaryForDownloadingIcon:(id)downloadingIcon;
-(BOOL)importState:(id)state;
@end

