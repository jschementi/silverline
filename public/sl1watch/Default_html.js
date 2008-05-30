function createSilverlight()
{
	var scene = new BallWatch.Page();
	var loader = Silverlight.createDelegate(scene, scene.handleLoad);
	Silverlight.createObjectEx(
	{
		source: "Loading.xaml",
		parentElement: document.getElementById("silverlightControlHost"),
		id: "SilverlightControl",
		properties: 
		{
			width: "100%",
			height: "100%",
			version: "1.0",
			background: "black"
		},
		events: 
		{
			onLoad:  loader,
			onError: SilverlightError
		}
	});
}

function SilverlightError(sender, args)
{
	var errorDiv = document.getElementById("errorLocation");

	if (errorDiv != null) 
	{
		var errorText = args.errorType + "- " + args.errorMessage;

		if (args.ErrorType == "ParserError") 
		{
			errorText += "<br>File: " + args.xamlFile;
			errorText += ", line " + args.lineNumber;
			errorText += " character " + args.charPosition;
		}
		else if (args.ErrorType == "RuntimeError") 
		{
			errorText += "<br>line " + args.lineNumber;
			errorText += " character " +  args.charPosition;
		}
		errorDiv.innerHTML = errorText;
	}
    var status = sender.findName("Status");
    if (status)
    {
        status.Text = args.errorMessage;
    }
}

if (!window.Silverlight) 
	window.Silverlight = {};

Silverlight.createDelegate = function(instance, method) 
{
	return function() 
	{
		return method.apply(instance, arguments);
	}
}

