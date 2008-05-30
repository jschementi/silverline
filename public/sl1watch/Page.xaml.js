if (!window.BallWatch)
	BallWatch = {};

BallWatch.Page = function() 
{
    this.AboutShown = false;
    this.Day = true;
}

BallWatch.Page.prototype =
{
	handleLoad: function(control, userContext, rootElement) 
	{
	    if (this.control)
	    {
	        return;
	    }
	    rootElement.findName("Status").Text+= "\nLoaded.";
      
      this.control = control;
      this.content = control.content;
      
      rootElement.Width = screen.width;
      rootElement.Height = screen.height;
      
      var downloader = this.control.createObject("Downloader");
      downloader.addEventListener("completed", Silverlight.createDelegate(this, this.Downloaded));
      this.PieProgress = new PieProgress(rootElement, downloader);
      downloader.open("GET", "Page.zip");
      downloader.Send();
  }
}

function CanvasLoaded(sender, eventArgs)
{
    if (this.control == null)
    {
        var watch = new BallWatch.Page();
        watch.handleLoad(sender.getHost(), null, sender);
    }
}

BallWatch.Page.prototype.ToDay = function(sender, eventArgs)
{
    var animation;
    if (this.Day)
    {
        animation = sender.findName("Night");
    }
    else
    {
        animation = sender.findName("Day");
    }
    animation.Begin();
    this.Day = !this.Day;
}

BallWatch.Page.prototype.ToNight = function(sender, eventArgs)
{
    var animation = sender.findName("Night");
    animation.Begin();
}

BallWatch.Page.prototype.Downloaded = function(sender, eventArgs)
{
  var xaml = sender.GetResponseText("Page.xaml");
  this.Watch = this.content.createFromXaml(xaml);
  
  this.content.Root.children.Clear();
  this.content.Root.children.Add(this.Watch);
	
  this.PageScale = sender.findName("PageScale");
	this.PageTranslation = sender.findName("PageTranslation");
	
  var dayButton = sender.findName("DayButton");
	dayButton.addEventListener("MouseLeftButtonDown", Silverlight.createDelegate(this, this.ToDay));
	
  var info = sender.findName("Info");
	info.addEventListener("MouseLeftButtonDown", Silverlight.createDelegate(this, this.OpenLink));
	var info = sender.findName("Logo");
	info.addEventListener("MouseLeftButtonDown", Silverlight.createDelegate(this, this.OpenLink));
	
  var about = sender.findName("AboutButton");
	about.addEventListener("MouseLeftButtonDown", Silverlight.createDelegate(this, this.ShowAbout));
	about = sender.findName("About");
	about.addEventListener("MouseLeftButtonDown", Silverlight.createDelegate(this, this.ShowAbout));
	
  var fullScreenButton = sender.findName("FullScreen");
	fullScreenButton.addEventListener("MouseLeftButtonDown", Silverlight.createDelegate(this, this.FullScreen));
  this.content.onResize = Silverlight.createDelegate(this, this._OnResize);
  this.content.onFullScreenChange = Silverlight.createDelegate(this, this._OnResize);
  this._Resize(this.content.ActualWidth, this.content.ActualHeight);

  this.UpdateSecondAnimation("SecondAnimation");
  this.UpdateSecondAnimation("ChronographSecondAnimation");
  this.Run();

  var animation = sender.findName("Day");
  animation.Begin();
}

/// This will increment the second hand in 1 second increments
BallWatch.Page.prototype.UpdateSecondAnimation = function(animationName)
{
    var animation = this.Watch.findName(animationName);
    animation.KeyFrames.Clear();
    for (var i = 0; i <= 60; i++)
    {
        var xaml = '<DiscreteDoubleKeyFrame xmlns="http://schemas.microsoft.com/client/2007" KeyTime="00:00:00"/>';
        var keyFrame = this.content.createFromXaml(xaml);
        keyFrame.KeyTime.Seconds = i;
        keyFrame.Value = i * 6;
        animation.KeyFrames.Add(keyFrame);
    }
}

BallWatch.Page.prototype.Run = function()
{
	var run = this.content.Root.findName("Run");
	var time = new Date();
	var timeString = time.toTimeString();
	var index = timeString.search(" ");
	timeString = timeString.substr(0, index);
	run.Begin();
	run.Seek(timeString);
	var date = time.getDate();
	var dateNumber = this.content.findName("DateNumber");
	dateNumber.Text = time.getDate().toString();
}

BallWatch.Page.prototype.ShowAbout = function(sender, eventArgs)
{
    var animation;
    if (this.AboutShown)
    {
        animation = sender.findName("HideAbout");    
    }
    else
    {
        animation = sender.findName("ShowAbout");    
    }
    animation.Begin();
    this.AboutShown = !this.AboutShown;
    var about = sender.findName("About");
    about.Visibility = "Visible";
}

BallWatch.Page.prototype.OpenLink = function(sender, eventArgs)
{
    window.open(sender.Tag, "_blank");
}

BallWatch.Page.prototype.FullScreen = function(sender, eventArgs)
{
    this.content.FullScreen = !this.content.FullScreen;
}

BallWatch.Page.prototype._OnResize = function(sender, eventArgs)
{
    this._Resize(this.content.ActualWidth, this.content.ActualHeight);
}

BallWatch.Page.prototype._Resize = function(width, height)
{
    if (width == 0 || height == 0)
    {
        return;
    }
    height = Math.min(height, screen.height);
    width = Math.min(width, screen.width);

    var scaleX = width / this.Watch.Width;
    var scaleY = height / this.Watch.Height;

    var scale = Math.min(scaleX, scaleY);
    this.PageScale.ScaleX = scale;
    this.PageScale.ScaleY = scale;

    this.PageTranslation.X = (width - this.Watch.Width * scale) / 2;
    this.PageTranslation.Y = (height - this.Watch.Height * scale) / 2;
}

var TopButtonPressed = false;
var BottomButtonPressed = false;
var ChronographState = 0; //0=stopped, 1 = running, 2=paused

function PressTopButton(sender, eventArgs)
{
  var animation = sender.findName("PressTopButton");
  animation.Begin();
	TopButtonPressed = sender.CaptureMouse();
	animation = sender.findName("StartChronograph");

	switch (ChronographState)
	{
    case 0: //Stopped
        animation.Begin();
        ChronographState = 1;
        break;

    case 1: //Running
        animation.Pause();
        ChronographState = 2;
        break;
            
    case 2: // Paused
        animation.Resume();
        ChronographState = 1;
        break;
	}
}

function ReleaseTopButton(sender, eventArgs)
{
	if (TopButtonPressed)
	{
		var animation = sender.findName("ReleaseTopButton");
		animation.Begin();
		TopButtonPressed = false;
	}
}

function PressBottomButton(sender, eventArgs)
{
	var animation = sender.findName("PressBottomButton");
	animation.Begin();
	animation = sender.findName("StartChronograph");
	animation.Stop();
	ChronographState = 0;
	BottomButtonPressed = sender.CaptureMouse();
}

function ReleaseBottomButton(sender, eventArgs)
{
	if (BottomButtonPressed)
	{
		var animation = sender.findName("ReleaseBottomButton");
		animation.Begin();
		BottomButtonPressed = false;
	}
}

