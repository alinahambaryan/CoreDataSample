//
//  ViewController.m
//  CoreDataSample
//
//  Created by Alina Hambaryan on 1/19/16.
//  Copyright © 2016 Alina Hambaryan. All rights reserved.
//

#import "NoteViewController.h"
#import <CoreData/CoreData.h>
#import "CoreDataManager.h"

@interface NoteViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic  ) IBOutlet UITableView       *notesTableView;
@property (strong, nonatomic) NSFetchedResultsController *fechedController;

@end

@implementation NoteViewController

+(instancetype)createInstance
{
    UIStoryboard *storyboard           = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NoteViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"NoteViewController"];
    
    return viewController;
}

-(void)awakeFromNib
{
    self.fechedController          = [[CoreDataManager sharedManager]fetchResultControllerForEntity:FetchRequestEntityTypeNote];
    self.fechedController.delegate = self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - UIViewcontroller lyfecycle
//-------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIBOutlets];
    
//    [self addNoteWithTimer];
//    [self removeNoteWithTimer];
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
    [self.notesTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NoteCell"];
}

-(void)addNoteWithTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(addNote)
                                                    userInfo:nil
                                                     repeats:YES];
    if (timer == nil)   {
        NSLog( @"Timer issue.");
    }
}

-(void)removeNoteWithTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:20.0
                                                      target:self
                                                    selector:@selector(deleteNote)
                                                    userInfo:nil
                                                     repeats:YES];
    if (timer == nil)   {
        NSLog( @"Timer issue.");
    }
}

-(void)addNote
{
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];

   [[CoreDataManager sharedManager] addNote:@{@"name": dateString} intoFolder:self.folder];
}

-(void)deleteNote
{
    if (self.fechedController.fetchedObjects[3]) {
        [[CoreDataManager sharedManager] deleteNote:self.fechedController.fetchedObjects[3]];
    }
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
    UITableViewCell *cell     = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath: indexPath];
    Note *note                = self.fechedController.fetchedObjects[indexPath.row];
    cell.textLabel.text       =  [NSString stringWithFormat:@"%li, %@",(long)indexPath.row, note.name];
    cell.detailTextLabel.text = note.info;
    
    return cell;
}


//-------------------------------------------------------------------------------------------
#pragma mark - NSFetchedResultsControllerDelegate lyfecycle
//-------------------------------------------------------------------------------------------

- (void)controllerWillChangeContent: (NSFetchedResultsController *)controller
{
    [self.notesTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.notesTableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.notesTableView insertRowsAtIndexPaths: @[newIndexPath]
                                  withRowAnimation: UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.notesTableView deleteRowsAtIndexPaths: @[indexPath]
                                  withRowAnimation: UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.notesTableView reloadRowsAtIndexPaths: @[indexPath]
                                  withRowAnimation: UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.notesTableView deleteRowsAtIndexPaths: @[indexPath]
                                  withRowAnimation: UITableViewRowAnimationFade];
            [self.notesTableView insertRowsAtIndexPaths: @[newIndexPath]
                                  withRowAnimation: UITableViewRowAnimationFade];
            break;
    }
}

@end
