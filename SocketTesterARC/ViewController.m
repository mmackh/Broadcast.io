//
//  ViewController.m
//  SocketTesterARC
//
//  Created by Kyeck Philipp on 01.06.12.
//  Copyright (c) 2012 beta_interactive. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    //socketIO.useSecure = YES;
    
    self.title = @"Messages";
    self.messages = [[NSMutableArray alloc] init];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(connect)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(organise)];
}

- (void)organise
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Change Username", @"Delete Conversation", @"Check Status", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"test");
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self connect];
}

- (void)connect
{
    [socketIO connectToHost:@"192.168.100.178" onPort:8080];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [socketIO disconnect];
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{    
    NSString *status = (NSString *)[[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"data"];
    
    if ([status isEqualToString:@"connected"])
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"] ==  nil)
        {
            
        }
        else
        {
            username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        }
        return;
    }
    
    [MessageSoundEffect playMessageReceivedSound];
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:status forKey:@"text"];
    [msg setObject:@"false" forKey:@"me"];
    [self.messages addObject:msg];
    
    [self finishGet];
}

- (void) socketIO:(SocketIO *)socket failedToConnectWithError:(NSError *)error
{
    NSLog(@"failedToConnectWithError() %@", error);
    
    [self connect];
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"%@", error);
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view controller
- (BubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *msg = [self.messages objectAtIndex:indexPath.row];
    return ([[msg objectForKey:@"me"] isEqualToString:@"true"]) ? BubbleMessageStyleOutgoing : BubbleMessageStyleIncoming;
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *msg = [self.messages objectAtIndex:indexPath.row];
    return [msg objectForKey:@"text"];

}

- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:text forKey:@"text"];
    [msg setObject:@"true" forKey:@"me"];
    [self.messages addObject:msg];
    
    [MessageSoundEffect playMessageSentSound];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"Maximilian:\n%@", text] forKey:@"payload"];
    
    [socketIO sendEvent:@"refresh" withData:dict];
    
    [self finishSend];
}

@end
