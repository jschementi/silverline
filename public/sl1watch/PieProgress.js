function PieProgress(root, downloader)
{
    this.Arc = root.findName("PieProgressArc");
    
    this.UpdateProgress(0);
    
    downloader.AddEventListener("DownloadProgressChanged", Silverlight.createDelegate(this, this.DownloadProgressChanged));
}

PieProgress.prototype.DownloadProgressChanged = function(sender, eventArgs)
{
    this.UpdateProgress(sender.downloadProgress);
}

PieProgress.prototype.UpdateProgress = function(percentage)
{
    var angle = percentage * 360;
    
    this.Arc.RotationAngle = angle;
    var x = Math.sin(angle * Math.PI/180) * 100;
    var y = -Math.cos(angle * Math.PI/180) * 100;
    
    this.Arc.IsLargeArc = (percentage > 0.5);

    this.Arc.Point = x + "," + y;
}

//This is the XAML for the pie progress
//	<Path Fill="Gold" Stroke="Black" x:Name="Progress" Canvas.Left="108" Canvas.Top="108">
//	<Path.Data>
//		<PathGeometry>
//			<PathGeometry.Figures>
//				<PathFigure IsClosed="True" StartPoint="0,0">
//					<PathFigure.Segments>
//						<LineSegment Point="0,-100"/>
//						<ArcSegment Point="100,0" RotationAngle="90" Size="100,100" SweepDirection="Clockwise" x:Name="PieProgressArc"/>
//					</PathFigure.Segments>	
//				</PathFigure>
//			</PathGeometry.Figures>
//		</PathGeometry>
//	</Path.Data>
//	</Path>

