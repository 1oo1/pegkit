#import "TDTestScaffold.h"
#import "PGParserFactory.h"
#import "PGParserGenVisitor.h"
#import "PGRootNode.h"
#import "GrammarActionsParser.h"

@interface GrammarActionsParserTest : XCTestCase
@property (nonatomic, retain) PGParserFactory *factory;
@property (nonatomic, retain) PGRootNode *root;
@property (nonatomic, retain) PGParserGenVisitor *visitor;
@property (nonatomic, retain) GrammarActionsParser *parser;
@property (nonatomic, retain) id mock;
@end

@implementation GrammarActionsParserTest

- (void)parser:(PKParser *)p didFailToMatch:(PKAssembly *)a {}

- (void)parser:(PKParser *)p didMatchLcurly:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchRcurly:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchName:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchColon:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchValue:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchComma:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchStructure:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchStructs:(PKAssembly *)a {}

- (void)dealloc {
    self.factory = nil;
    self.root = nil;
    self.visitor = nil;
    self.parser = nil;
    self.mock = nil;
    [super dealloc];
}


- (void)setUp {
    self.factory = [PGParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"grammar_actions" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"GrammarActions";
    
    self.visitor = [[[PGParserGenVisitor alloc] init] autorelease];
    _visitor.enableMemoization = NO;
    
    [_root visit:_visitor];
    
#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/GrammarActionsParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/GrammarActionsParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif

    self.parser = [[[GrammarActionsParser alloc] initWithDelegate:_mock] autorelease];
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testFooBarBaz {
    NSString *s = @"foo bar baz";
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:s error:&err];
    TDNil(err);
    
    TDEqualObjects(TDAssembly(@"[foo, bar, baz]foo/bar/baz^"), [res description]);
}

@end
