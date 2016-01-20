//
//  FolderViewController.m
//  CoreDataSample
//
//  Created by Alina Hambaryan on 1/19/16.
//  Copyright © 2016 Alina Hambaryan. All rights reserved.
//

#import "FolderViewController.h"
#import "Folder.h"
#import "CoreDataManager.h"
#import "NoteViewController.h"

@interface FolderViewController()<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic  ) IBOutlet UITableView       *foldersTableView;
@property (strong, nonatomic) NSFetchedResultsController *fechedController;

@end

@implementation FolderViewController

-(void)awakeFromNib
{
    self.fechedController = [[CoreDataManager sharedManager]fetchResultControllerForEntity:FetchRequestEntityTypeFolder];
    self.fechedController.delegate = self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - UIViewcontroller lyfecycle
//-------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIBOutlets];
    
//    [self addFolderWithTimer];
//    [self removeFolderWithTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Private Methods
//-------------------------------------------------------------------------------------------

-(void)initIBOutlets
{
    [self.foldersTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FolderCell"];
}

-(void)addFolderWithTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(addFolder)
                                                    userInfo:nil
                                                     repeats:YES];
    if (timer == nil)   {
        NSLog( @"Timer issue.");
    }
}

-(void)removeFolderWithTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:20.0
                                                      target:self
                                                    selector:@selector(deleteFolder)
                                                    userInfo:nil
                                                     repeats:YES];
    if (timer == nil)   {
        NSLog( @"Timer issue.");
    }
}

-(void)addFolder
{
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    
    [[CoreDataManager sharedManager] addFolder:@{@"name": dateString}];
    
    NSLog(@"addFolder number of objects = %lu", self.fechedController.fetchedObjects.count);
}

-(void)deleteFolder
{
    if (self.fechedController.fetchedObjects[3]) {
        [[CoreDataManager sharedManager] deleteFolder:self.fechedController.fetchedObjects[3]];
    }
    
    NSLog(@"deleteFolder number of objects = %lu", self.fechedController.fetchedObjects.count);
}

//-------------------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource
//-------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fechedController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCell" forIndexPath: indexPath];
    Folder *folder        = self.fechedController.fetchedObjects[indexPath.row];
    cell.textLabel.text   = [NSString stringWithFormat:@"%li, %@",(long)indexPath.row, folder.name];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteViewController *viewController = [NoteViewController createInstance];
    viewController.folder              = self.fechedController.fetchedObjects[indexPath.row];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

//-------------------------------------------------------------------------------------------
#pragma mark - NSFetchedResultsControllerDelegate
//-------------------------------------------------------------------------------------------

- (void)controllerWillChangeContent: (NSFetchedResultsController *)controller
{
    [self.foldersTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.foldersTableView endUpdates];
}

/*
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type){
        case NSFetchedResultsChangeInsert:
            [self.foldersTableView insertSections: [NSIndexSet indexSetWithIndex:sectionIndex]
                         withRowAnimation : UITableViewRowAnimationFade];
        case NSFetchedResultsChangeDelete:
            [self.foldersTableView deleteSections: [NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation: UITableViewRowAnimationFade];
        default: break;
    }
}*/

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSLog(@"type = %lu", (unsigned long)type);

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.foldersTableView insertRowsAtIndexPaths: @[newIndexPath]
                                       withRowAnimation: UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.foldersTableView deleteRowsAtIndexPaths: @[indexPath]
                                       withRowAnimation: UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.foldersTableView reloadRowsAtIndexPaths: @[indexPath]
                                       withRowAnimation: UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.foldersTableView deleteRowsAtIndexPaths: @[indexPath]
                                       withRowAnimation: UITableViewRowAnimationFade];
            [self.foldersTableView insertRowsAtIndexPaths: @[newIndexPath]
                                       withRowAnimation: UITableViewRowAnimationFade];
            break;
    }
}

@end
