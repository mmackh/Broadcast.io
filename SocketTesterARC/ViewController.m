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
    [socketIO connectToHost:@"192.168.100.178" onPort:8080];
    
    self.title = @"Messages";
    self.messages = [[NSMutableArray alloc] init];
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    [MessageSoundEffect playMessageReceivedSound];
    
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:[[[packet.dataAsJSON objectForKey:@"args"] objectAtIndex:0] objectForKey:@"data"] forKey:@"text"];
    [msg setObject:@"false" forKey:@"me"];
    [self.messages addObject:msg];
    
    [self finishGet];
}

- (void) socketIO:(SocketIO *)socket failedToConnectWithError:(NSError *)error
{
    NSLog(@"failedToConnectWithError() %@", error);
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
    [dict setObject:text forKey:@"payload"];
    
    [socketIO sendEvent:@"refresh" withData:dict];
    
    [self finishSend];
}

@end
