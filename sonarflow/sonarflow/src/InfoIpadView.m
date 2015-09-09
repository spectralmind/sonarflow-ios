#import "InfoIpadView.h"

#import "InfoIpadViewTitleView.h"
#import "InfoIpadViewContentCell.h"

static const CGFloat kTitleViewHeight = 90.f;
static const CGFloat kSectionContentHeightDefault  = 20.f;


@interface InfoIpadView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) InfoIpadViewTitleView *titleView;
@property (nonatomic, readonly) UITableView *tableView;

@end

@implementation InfoIpadView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {	
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        _titleView = [[InfoIpadViewTitleView alloc] initWithFrame:CGRectZero];
		_titleView.backgroundColor = [UIColor clearColor];
		[self addSubview:_titleView];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		[self addSubview:_tableView];
	}
    return self;
}

#pragma mark - Public Methods

- (void)reloadData {
	self.titleView.title = [self.infoIpadViewDelegate infoIpadViewStringForTitle:self];
	[self setNeedsLayout];
	[self.tableView reloadData];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
	[self.tableView setContentOffset:contentOffset animated:animated];
}

- (void)flashScrollIndicators {
	[self.tableView flashScrollIndicators];
}

- (void)addFacebookButton:(UIButton *)fbButton andTwitterButton:(UIButton *)twButton {
	[self.titleView addFacebookButton:fbButton andTwitterButton:twButton];
}

#pragma mark - Private Methods

- (void)layoutSubviews {
	[super layoutSubviews];

	self.titleView.frame = CGRectMake(0.f, 0.f, self.bounds.size.width, kTitleViewHeight);
	self.tableView.frame = CGRectMake(0.f, kTitleViewHeight, self.bounds.size.width, self.bounds.size.height - kTitleViewHeight);
}

#pragma mark - Properties

- (void)setInfoIpadViewDelegate:(id<InfoIpadViewDelegate>)theInfoIpadViewDelegate {
	_infoIpadViewDelegate = theInfoIpadViewDelegate;
	self.titleView.infoIpadViewCloseDelegate = theInfoIpadViewDelegate;
}

- (void)removeSubviewsFromContainerView:(UIView *)containerView {
	for (UIView *v in containerView.subviews) {
		[v removeFromSuperview];
	}
}

- (void)placeView:(UIView *)view inContainerView:(UIView *)containerView {
	if([containerView.subviews containsObject:view]) {
		return;
	}

	[self removeSubviewsFromContainerView:containerView];
	[containerView addSubview:view];
	CGRect rect = containerView.frame;
	rect.origin.x = 0;
	rect.origin.y = 0;
	[view setFrame:rect];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat rowHeight = 0.f;
	
	if ([self.infoIpadViewDelegate infoIpadView:self stateOfRowWithIndex:indexPath.row] == InfoIpadViewSectionStateLoaded) {
		rowHeight = [self.infoIpadViewDelegate infoIpadView:self heightForContentOfRowWithIndex:indexPath.row];
	} else {
		rowHeight = kSectionContentHeightDefault;
	}
	
	if (indexPath.row+1 < [self.infoIpadViewDelegate infoIpadViewNumberOfRows:self]) {
		rowHeight += [self.infoIpadViewDelegate infoIpadViewSpaceBetweenRows:self];
	}
	
	return rowHeight;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ArtistInfoIpadViewMediaCell";
	
	InfoIpadViewContentCell *cell = (InfoIpadViewContentCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[InfoIpadViewContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.title = [self.infoIpadViewDelegate infoIpadView:self titleForRowWithIndex:indexPath.row];
	cell.contentHeight = [self.infoIpadViewDelegate infoIpadView:self heightForContentOfRowWithIndex:indexPath.row];
	
	InfoIpadViewSectionState state = InfoIpadViewSectionStateLoaded;
	if([self.infoIpadViewDelegate respondsToSelector:@selector(infoIpadView:stateOfRowWithIndex:)]) {
		state = [self.infoIpadViewDelegate infoIpadView:self stateOfRowWithIndex:indexPath.row];
	}
	
	// TODO height
	switch (state) {
		case InfoIpadViewSectionStateLoading:
			[self removeSubviewsFromContainerView:cell.containerView];
			cell.errorLabel.text = @"";
			[cell.spinner startAnimating];
			break;
			
		case InfoIpadViewSectionStateFailed:
			[self removeSubviewsFromContainerView:cell.containerView];
			[cell.spinner stopAnimating];
			if([self.infoIpadViewDelegate respondsToSelector:@selector(infoIpadView:failedMessageOfRowWithIndex:)]) {
				cell.errorLabel.text = [self.infoIpadViewDelegate infoIpadView:self failedMessageOfRowWithIndex:indexPath.row];
			} else {
				cell.errorLabel.text = @"";
			}

			break;
			
		case InfoIpadViewSectionStateLoaded:
			[cell.spinner stopAnimating];
			cell.errorLabel.text = @"";
			[self placeView:[self.infoIpadViewDelegate infoIpadView:self contentViewForRowWithIndex:indexPath.row] inContainerView:cell.containerView];
			break;
			
		default:
			break;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.infoIpadViewDelegate infoIpadViewNumberOfRows:self];
}

@end
