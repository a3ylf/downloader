$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

Add-Type @'
using System.Runtime.InteropServices;

public static class DlrTaskbarIdentity
{
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    public static extern int SetCurrentProcessExplicitAppUserModelID(string appID);
}
'@

[void] [DlrTaskbarIdentity]::SetCurrentProcessExplicitAppUserModelID('DLR.Downloader')

$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="DLR Downloader"
    Width="760"
    Height="470"
    MinWidth="680"
    MinHeight="440"
    WindowStartupLocation="CenterScreen"
    WindowStyle="None"
    ResizeMode="CanResizeWithGrip"
    AllowsTransparency="True"
    Background="Transparent"
    FontFamily="Bahnschrift, Segoe UI"
    Foreground="#F7F9FF"
    TextOptions.TextFormattingMode="Display"
    UseLayoutRounding="True">

    <Window.Resources>
        <SolidColorBrush x:Key="TextPrimary" Color="#F1EDFF"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#A89BBC"/>
        <SolidColorBrush x:Key="ControlFill" Color="#900B0920"/>
        <SolidColorBrush x:Key="ControlStroke" Color="#463E2578"/>
        <SolidColorBrush x:Key="ControlHover" Color="#B4141033"/>
        <SolidColorBrush x:Key="AccentFill" Color="#5C16DF"/>
        <SolidColorBrush x:Key="AccentHover" Color="#762CFF"/>

        <Style x:Key="GlassButton" TargetType="Button">
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="Background" Value="{StaticResource ControlFill}"/>
            <Setter Property="BorderBrush" Value="{StaticResource ControlStroke}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="14,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border
                            x:Name="ButtonShell"
                            CornerRadius="6"
                            Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}"
                            BorderThickness="{TemplateBinding BorderThickness}"
                            SnapsToDevicePixels="True">
                            <ContentPresenter
                                HorizontalAlignment="Center"
                                VerticalAlignment="Center"
                                Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ButtonShell" Property="Background" Value="{StaticResource ControlHover}"/>
                                <Setter TargetName="ButtonShell" Property="BorderBrush" Value="#A369F8"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="ButtonShell" Property="Opacity" Value="0.76"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="ButtonShell" Property="Opacity" Value="0.42"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="AccentButton" TargetType="Button" BasedOn="{StaticResource GlassButton}">
            <Setter Property="Background" Value="{StaticResource AccentFill}"/>
            <Setter Property="BorderBrush" Value="#8E54FF"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Effect">
                <Setter.Value>
                    <DropShadowEffect Color="#5B19E6" BlurRadius="18" ShadowDepth="0" Opacity="0.78"/>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="{StaticResource AccentHover}"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style x:Key="WindowButton" TargetType="Button" BasedOn="{StaticResource GlassButton}">
            <Setter Property="Width" Value="36"/>
            <Setter Property="Height" Value="30"/>
            <Setter Property="Margin" Value="2,0"/>
            <Setter Property="Padding" Value="0"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderBrush" Value="Transparent"/>
            <Setter Property="FontSize" Value="13"/>
        </Style>

        <Style TargetType="ComboBoxItem">
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Padding" Value="10,6"/>
            <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBoxItem">
                        <Border x:Name="ItemShell" Background="{TemplateBinding Background}" CornerRadius="6" Margin="4,2">
                            <ContentPresenter Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsHighlighted" Value="True">
                                <Setter TargetName="ItemShell" Property="Background" Value="#442D1670"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="ItemShell" Property="Background" Value="#665D1BE5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="GlassCombo" TargetType="ComboBox">
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="Background" Value="{StaticResource ControlFill}"/>
            <Setter Property="BorderBrush" Value="{StaticResource ControlStroke}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="10,0"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <Border
                                x:Name="ComboShell"
                                CornerRadius="6"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}">
                                <Grid>
                                    <ContentPresenter
                                        Margin="11,0,34,0"
                                        VerticalAlignment="Center"
                                        HorizontalAlignment="Left"
                                        Content="{TemplateBinding SelectionBoxItem}"/>
                                    <Path
                                        Data="M 0 0 L 4 4 L 8 0"
                                        Stroke="#E8ECFF"
                                        StrokeThickness="1.4"
                                        HorizontalAlignment="Right"
                                        VerticalAlignment="Center"
                                        Margin="0,0,12,0"/>
                                </Grid>
                            </Border>
                            <ToggleButton
                                Focusable="False"
                                Background="Transparent"
                                BorderThickness="0"
                                Opacity="0"
                                ClickMode="Press"
                                IsChecked="{Binding IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}"/>
                            <Popup
                                x:Name="PART_Popup"
                                Placement="Bottom"
                                AllowsTransparency="True"
                                Focusable="False"
                                IsOpen="{TemplateBinding IsDropDownOpen}"
                                PopupAnimation="Fade">
                                <Border
                                    MinWidth="{Binding ActualWidth, RelativeSource={RelativeSource TemplatedParent}}"
                                    Margin="0,5,0,0"
                                    Padding="3"
                                    CornerRadius="6"
                                    Background="#FA0A0920"
                                    BorderBrush="#7A6B35CF"
                                    BorderThickness="1">
                                    <Border.Effect>
                                        <DropShadowEffect Color="#0A1024" BlurRadius="24" ShadowDepth="5" Opacity="0.8"/>
                                    </Border.Effect>
                                    <ScrollViewer MaxHeight="240" VerticalScrollBarVisibility="Auto">
                                        <ItemsPresenter/>
                                    </ScrollViewer>
                                </Border>
                            </Popup>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ComboShell" Property="Background" Value="{StaticResource ControlHover}"/>
                                <Setter TargetName="ComboShell" Property="BorderBrush" Value="#A369F8"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="ComboShell" Property="Opacity" Value="0.42"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SlimProgress" TargetType="ProgressBar">
            <Setter Property="Height" Value="2"/>
            <Setter Property="Background" Value="#241D0C54"/>
            <Setter Property="Foreground" Value="#9D6CFF"/>
            <Setter Property="BorderThickness" Value="0"/>
        </Style>
    </Window.Resources>

    <Grid Margin="16">
        <Border Name="WindowShell" CornerRadius="15" BorderBrush="#854C2598" BorderThickness="1" SnapsToDevicePixels="True">
            <Border.Effect>
                <DropShadowEffect Color="#03020B" BlurRadius="32" ShadowDepth="10" Opacity="0.95"/>
            </Border.Effect>
            <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                    <GradientStop Color="#FA080716" Offset="0"/>
                    <GradientStop Color="#FA0B0922" Offset="0.55"/>
                    <GradientStop Color="#FA060610" Offset="1"/>
                </LinearGradientBrush>
            </Border.Background>
            <Grid ClipToBounds="True">
                <Ellipse Width="330" Height="250" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,-150,-90,0" Fill="#251D0E6C">
                    <Ellipse.Effect><BlurEffect Radius="62"/></Ellipse.Effect>
                </Ellipse>
                <Rectangle Fill="#50020108"/>
                <Path Data="M 0,45 L 585,45 L 599,31 L 735,31" Stroke="#482C166E" StrokeThickness="1" HorizontalAlignment="Left" VerticalAlignment="Top"/>
                <Path Data="M 0,398 L 574,398 L 590,413 L 736,413" Stroke="#482C166E" StrokeThickness="1" HorizontalAlignment="Left" VerticalAlignment="Top"/>

                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="46"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="34"/>
                    </Grid.RowDefinitions>

                    <Grid Name="TitleBar" Grid.Row="0" Background="#68060413" Margin="1,1,1,0">
                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="18,0,0,0">
                            <Border Width="29" Height="29" CornerRadius="7" Background="#250F0A35" BorderBrush="#87522ABE" BorderThickness="1">
                                <Grid>
                                    <Path Data="M 9,16 L 9,20 M 14,11 L 14,20 M 19,14 L 19,20" Stroke="#A873FF" StrokeThickness="1.5" StrokeStartLineCap="Round" StrokeEndLineCap="Round"/>
                                    <Path Data="M 7,9 L 7,7 M 14,7 L 14,5 M 21,9 L 21,7" Stroke="#A873FF" StrokeThickness="1"/>
                                </Grid>
                            </Border>
                            <TextBlock Name="TitleText" Text="DLR DOWNLOADER" Margin="11,0,0,0" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                        </StackPanel>
                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" Margin="0,0,10,0">
                            <Button Name="MinimizeButton" Content="−" Style="{StaticResource WindowButton}" Foreground="#AC75FF"/>
                            <Button Name="MaximizeButton" Content="□" Style="{StaticResource WindowButton}" Foreground="#AC75FF"/>
                            <Button Name="CloseButton" Content="×" Style="{StaticResource WindowButton}" Foreground="#AC75FF"/>
                        </StackPanel>
                    </Grid>

                    <Grid Grid.Row="1" Margin="34,16,34,10">
                        <Grid.ColumnDefinitions><ColumnDefinition Width="1.48*"/><ColumnDefinition Width="38"/><ColumnDefinition Width="0.92*"/></Grid.ColumnDefinitions>
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="16"/><RowDefinition Height="38"/><RowDefinition Height="14"/>
                                <RowDefinition Height="16"/><RowDefinition Height="38"/><RowDefinition Height="14"/>
                                <RowDefinition Height="16"/><RowDefinition Height="38"/><RowDefinition Height="16"/>
                                <RowDefinition Height="40"/>
                            </Grid.RowDefinitions>
                            <TextBlock Grid.Row="0" Text="VIDEO OR POST LINK" FontSize="9" FontWeight="SemiBold" Foreground="#B3A6CE"/>
                            <Border Grid.Row="1" CornerRadius="6" Background="{StaticResource ControlFill}" BorderBrush="{StaticResource ControlStroke}" BorderThickness="1">
                                <Grid>
                                    <TextBox Name="URLInput" Margin="11,0,34,0" VerticalContentAlignment="Center" Background="Transparent" BorderThickness="0" Foreground="{StaticResource TextPrimary}" CaretBrush="#FFFFFF" FontSize="11"/>
                                    <TextBlock Name="URLPlaceholder" Text="https://example.com/video" Margin="12,0,34,0" VerticalAlignment="Center" Foreground="#6F658C" FontSize="11" IsHitTestVisible="False"/>
                                    <TextBlock Text="&#xE71B;" FontFamily="Segoe MDL2 Assets" FontSize="12" Foreground="#A96DFF" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,12,0"/>
                                </Grid>
                            </Border>
                            <Grid Grid.Row="3"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="14"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                <TextBlock Text="DOWNLOAD AS" FontSize="9" FontWeight="SemiBold" Foreground="#B3A6CE"/><TextBlock Grid.Column="2" Text="MAXIMUM QUALITY" FontSize="9" FontWeight="SemiBold" Foreground="#B3A6CE"/>
                            </Grid>
                            <Grid Grid.Row="4"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="14"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                <ComboBox Name="FormatCombo" Style="{StaticResource GlassCombo}" SelectedIndex="0"><ComboBoxItem Content="AUDIO (MP3)"/><ComboBoxItem Content="VIDEO (MP4)"/></ComboBox>
                                <ComboBox Name="QualityCombo" Grid.Column="2" Style="{StaticResource GlassCombo}" SelectedIndex="0" IsEnabled="False" Opacity="0.48"><ComboBoxItem Content="BEST AVAILABLE"/><ComboBoxItem Content="1080P"/><ComboBoxItem Content="720P"/><ComboBoxItem Content="480P"/></ComboBox>
                            </Grid>
                            <TextBlock Grid.Row="6" Text="SAVE TO" FontSize="9" FontWeight="SemiBold" Foreground="#B3A6CE"/>
                            <Grid Grid.Row="7"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="10"/><ColumnDefinition Width="88"/></Grid.ColumnDefinitions>
                                <Border CornerRadius="6" Background="{StaticResource ControlFill}" BorderBrush="{StaticResource ControlStroke}" BorderThickness="1">
                                    <TextBox Name="OutputInput" Margin="11,0" VerticalContentAlignment="Center" Background="Transparent" BorderThickness="0" Foreground="{StaticResource TextPrimary}" CaretBrush="#FFFFFF" FontSize="10"/>
                                </Border>
                                <Button Name="BrowseButton" Grid.Column="2" Content="BROWSE" Style="{StaticResource GlassButton}" Foreground="#AD78FF"/>
                            </Grid>
                            <Grid Grid.Row="9"><Grid.ColumnDefinitions><ColumnDefinition Width="1.18*"/><ColumnDefinition Width="10"/><ColumnDefinition Width="0.72*"/></Grid.ColumnDefinitions>
                                <Button Name="DownloadButton" Style="{StaticResource AccentButton}"><StackPanel Orientation="Horizontal"><TextBlock Text="&#xE896;" FontFamily="Segoe MDL2 Assets" FontSize="13" Margin="0,0,8,0"/><TextBlock Text="DOWNLOAD" VerticalAlignment="Center"/></StackPanel></Button>
                                <Button Name="OpenFolderButton" Grid.Column="2" Content="OPEN FOLDER" Style="{StaticResource GlassButton}" Foreground="#B17CFF"/>
                            </Grid>
                        </Grid>

                        <Grid Grid.Column="2">
                            <Grid.RowDefinitions><RowDefinition Height="245"/><RowDefinition Height="40"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                            <Canvas HorizontalAlignment="Center" VerticalAlignment="Center" Width="210" Height="210">
                                <Ellipse Canvas.Left="6" Canvas.Top="6" Width="198" Height="198" Stroke="#462D168A" StrokeThickness="1" StrokeDashArray="2,4"/>
                                <Ellipse Canvas.Left="19" Canvas.Top="19" Width="172" Height="172" Stroke="#704A22C9" StrokeThickness="1"/>
                                <Ellipse Canvas.Left="31" Canvas.Top="31" Width="148" Height="148" Stroke="#704A22C9" StrokeThickness="1"/>
                                <Ellipse Canvas.Left="47" Canvas.Top="47" Width="116" Height="116" Stroke="#7B6433E3" StrokeThickness="1"/>
                                <Ellipse Canvas.Left="67" Canvas.Top="67" Width="76" Height="76" Fill="#17190545" Stroke="#A25B2DEB" StrokeThickness="1"/>
                                <Ellipse Canvas.Left="101" Canvas.Top="37" Width="5" Height="5" Fill="#B679FF"/><Ellipse Canvas.Left="33" Canvas.Top="31" Width="4" Height="4" Fill="#7B46D9"/><Ellipse Canvas.Left="173" Canvas.Top="47" Width="4" Height="4" Fill="#7B46D9"/><Ellipse Canvas.Left="32" Canvas.Top="171" Width="4" Height="4" Fill="#7B46D9"/><Ellipse Canvas.Left="176" Canvas.Top="171" Width="4" Height="4" Fill="#7B46D9"/>
                                <Path Canvas.Left="66" Canvas.Top="72" Data="M 18,38 L 18,54 Q 18,61 25,61 L 60,61 Q 67,61 67,54 L 67,48 M 31,31 L 31,46 M 44,20 L 44,46 M 57,31 L 57,46" Stroke="#A66AFF" StrokeThickness="3" StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round"/>
                            </Canvas>
                            <Border Name="StatusPill" Grid.Row="1" CornerRadius="6" Background="#710A0920" BorderBrush="#452A1762" BorderThickness="1">
                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center"><Ellipse Name="StatusDot" Width="7" Height="7" Fill="#51D68B" Margin="0,0,8,0"><Ellipse.Effect><DropShadowEffect Color="#51D68B" BlurRadius="7" ShadowDepth="0" Opacity="0.9"/></Ellipse.Effect></Ellipse><TextBlock Name="StatusText" Text="READY." FontSize="10" Foreground="{StaticResource TextSecondary}"/></StackPanel>
                            </Border>
                        </Grid>
                    </Grid>

                    <Border Name="ActivityCard" Grid.Row="2" Margin="34,0,34,8" BorderBrush="#3C26135C" BorderThickness="0,1,0,0" Background="Transparent">
                        <Grid VerticalAlignment="Center"><Grid.ColumnDefinitions><ColumnDefinition Width="22"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="10"/><ColumnDefinition Width="*"/><ColumnDefinition Width="120"/></Grid.ColumnDefinitions>
                            <TextBlock Name="ActivityIcon" Text="&#x2193;" Foreground="#8F58ED" FontSize="15" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            <TextBlock Name="ActivityTitle" Grid.Column="1" Text="READY TO DOWNLOAD" FontSize="9" FontWeight="SemiBold" Foreground="#B9A8D9" VerticalAlignment="Center"/>
                            <TextBlock Name="ActivityText" Grid.Column="3" Text="PASTE A LINK, CHOOSE THE OPTIONS, AND CLICK DOWNLOAD." FontSize="8" Foreground="#86799E" VerticalAlignment="Center" TextTrimming="CharacterEllipsis"/>
                            <ProgressBar Name="DownloadProgress" Grid.Column="4" Style="{StaticResource SlimProgress}" IsIndeterminate="True" Visibility="Collapsed" VerticalAlignment="Center"/>
                        </Grid>
                    </Border>
                </Grid>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

$spectrumXamlPath = Join-Path $PSScriptRoot 'ui_spectrum.xaml'
if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot) -and (Test-Path -LiteralPath $spectrumXamlPath -PathType Leaf)) {
    $xaml = Get-Content -LiteralPath $spectrumXamlPath -Raw
}
else {
    $embeddedXamlBase64 = '__DLR_EMBEDDED_XAML__'
    $xaml = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($embeddedXamlBase64))
}

$window = [Windows.Markup.XamlReader]::Parse($xaml)

function Find-Control([string] $name) {
    return $window.FindName($name)
}

$titleBar = Find-Control 'TitleBar'
$titleText = Find-Control 'TitleText'
$versionText = Find-Control 'VersionText'
$minimizeButton = Find-Control 'MinimizeButton'
$maximizeButton = Find-Control 'MaximizeButton'
$closeButton = Find-Control 'CloseButton'
$urlInput = Find-Control 'URLInput'
$urlPlaceholder = Find-Control 'URLPlaceholder'
$formatCombo = Find-Control 'FormatCombo'
$qualityCombo = Find-Control 'QualityCombo'
$outputInput = Find-Control 'OutputInput'
$browseButton = Find-Control 'BrowseButton'
$downloadButton = Find-Control 'DownloadButton'
$openFolderButton = Find-Control 'OpenFolderButton'
$statusDot = Find-Control 'StatusDot'
$statusText = Find-Control 'StatusText'
$activityIcon = Find-Control 'ActivityIcon'
$activityTitle = Find-Control 'ActivityTitle'
$activityText = Find-Control 'ActivityText'
$downloadProgress = Find-Control 'DownloadProgress'
$sidebarLogo = Find-Control 'SidebarLogo'
$heroLogo = Find-Control 'HeroLogo'
$updateButton = Find-Control 'UpdateButton'
$downloadNavButton = Find-Control 'DownloadNavButton'
$historyButton = Find-Control 'HistoryButton'
$downloadPage = Find-Control 'DownloadPage'
$historyPage = Find-Control 'HistoryPage'
$historyList = Find-Control 'HistoryList'
$emptyHistoryPanel = Find-Control 'EmptyHistoryPanel'
$clearHistoryButton = Find-Control 'ClearHistoryButton'

$uiIconPath = Join-Path $PSScriptRoot 'ui_icon.png'
if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot) -and (Test-Path -LiteralPath $uiIconPath -PathType Leaf)) {
    $iconBytes = [IO.File]::ReadAllBytes($uiIconPath)
}
else {
    $iconBytes = [Convert]::FromBase64String('__DLR_EMBEDDED_ICON__')
}
$iconStream = [IO.MemoryStream]::new($iconBytes)
try {
    $iconBitmap = [Windows.Media.Imaging.BitmapImage]::new()
    $iconBitmap.BeginInit()
    $iconBitmap.CacheOption = [Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $iconBitmap.StreamSource = $iconStream
    $iconBitmap.EndInit()
    $iconBitmap.Freeze()
    $window.Icon = $iconBitmap
    $sidebarLogo.Source = $iconBitmap
    $heroLogo.Source = $iconBitmap
}
finally {
    $iconStream.Dispose()
}

$appDirectory = $env:DLR_APP_DIR
$appVersion = $env:DLR_APP_VERSION
$appProcessId = 0
[void] [int]::TryParse($env:DLR_APP_PID, [ref] $appProcessId)
if ([string]::IsNullOrWhiteSpace($appDirectory)) {
    $appDirectory = [AppDomain]::CurrentDomain.BaseDirectory
}
if ([string]::IsNullOrWhiteSpace($appVersion)) {
    $appVersion = 'dev'
}
if ($appProcessId -le 0) {
    $appProcessId = [Diagnostics.Process]::GetCurrentProcess().Id
}

$titleText.Text = 'DLR'
$versionText.Text = $appVersion
$outputInput.Text = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Downloads'

function Install-StartMenuShortcut {
    $programsDirectory = $env:DLR_START_MENU_DIR
    if ([string]::IsNullOrWhiteSpace($programsDirectory)) {
        $programsDirectory = [Environment]::GetFolderPath('Programs')
    }
    if ([string]::IsNullOrWhiteSpace($programsDirectory)) {
        return
    }

    $target = Join-Path $appDirectory 'dlr-gui.exe'
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
        return
    }

    $shortcutPath = Join-Path $programsDirectory 'DLR.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $target
    $shortcut.WorkingDirectory = $appDirectory
    $shortcut.Description = 'DLR video and audio downloader'
    $shortcut.IconLocation = "$target,0"
    $shortcut.WindowStyle = 1
    $shortcut.Save()
}

try {
    Install-StartMenuShortcut
}
catch {
    # A locked-down Windows account may block Start menu changes. The app can
    # still run portably, so shortcut creation must never prevent startup.
}

if ($env:DLR_UI_VALIDATE -eq '1') {
    return
}

function New-Brush([string] $color) {
    return [Windows.Media.BrushConverter]::new().ConvertFromString($color)
}

$historyDirectory = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'DLR'
$historyPath = Join-Path $historyDirectory 'history.json'
$thumbnailDirectory = Join-Path $historyDirectory 'thumbnails'
$script:history = @()

function Load-History {
    $script:history = @()
    if (-not (Test-Path -LiteralPath $historyPath -PathType Leaf)) {
        return
    }

    try {
        $saved = Get-Content -LiteralPath $historyPath -Raw | ConvertFrom-Json
        if ($null -ne $saved) {
            $script:history = @($saved) | Select-Object -First 100
        }
    }
    catch {
        # A partial or manually edited history file should not prevent startup.
        $script:history = @()
    }
}

function Save-History {
    [IO.Directory]::CreateDirectory($historyDirectory) | Out-Null
    $temporaryPath = $historyPath + '.tmp'
    $json = ConvertTo-Json -InputObject @($script:history) -Depth 4
    [IO.File]::WriteAllText($temporaryPath, $json, [Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $temporaryPath -Destination $historyPath -Force
}

function Cache-HistoryThumbnail([string] $thumbnailUrl) {
    if ([string]::IsNullOrWhiteSpace($thumbnailUrl)) {
        return ''
    }

    try {
        $uri = [Uri] $thumbnailUrl
        if (-not $uri.IsAbsoluteUri -or ($uri.Scheme -ne 'http' -and $uri.Scheme -ne 'https')) {
            return ''
        }
        [IO.Directory]::CreateDirectory($thumbnailDirectory) | Out-Null
        $thumbnailPath = Join-Path $thumbnailDirectory (([Guid]::NewGuid().ToString('N')) + '.img')
        $request = [Net.HttpWebRequest]::Create($uri)
        $request.UserAgent = 'DLR/' + $appVersion
        $request.Timeout = 5000
        $request.ReadWriteTimeout = 5000
        $response = $request.GetResponse()
        $responseStream = $response.GetResponseStream()
        $fileStream = [IO.File]::Create($thumbnailPath)
        try {
            $responseStream.CopyTo($fileStream)
        }
        finally {
            $fileStream.Dispose()
            $responseStream.Dispose()
            $response.Dispose()
        }
        return $thumbnailPath
    }
    catch {
        if (-not [string]::IsNullOrWhiteSpace($thumbnailPath) -and (Test-Path -LiteralPath $thumbnailPath -PathType Leaf)) {
            Remove-Item -LiteralPath $thumbnailPath -Force -ErrorAction SilentlyContinue
        }
        return ''
    }
}

function New-HistoryBitmap([string] $source) {
    if ([string]::IsNullOrWhiteSpace($source)) {
        return $null
    }

    $stream = $null
    try {
        $stream = [IO.File]::OpenRead($source)
        $bitmap = [Windows.Media.Imaging.BitmapImage]::new()
        $bitmap.BeginInit()
        $bitmap.CacheOption = [Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.StreamSource = $stream
        $bitmap.EndInit()
        $bitmap.Freeze()
        return $bitmap
    }
    catch {
        return $null
    }
    finally {
        if ($null -ne $stream) {
            $stream.Dispose()
        }
    }
}

function Add-HistoryRecord($metadata, [string] $sourceUrl, [string] $format) {
    $title = $sourceUrl
    $filePath = ''
    $thumbnailUrl = ''
    $duration = ''
    $provider = ''

    if ($null -ne $metadata) {
        if (-not [string]::IsNullOrWhiteSpace([string] $metadata.title)) { $title = [string] $metadata.title }
        if (-not [string]::IsNullOrWhiteSpace([string] $metadata.filepath)) { $filePath = [string] $metadata.filepath }
        if (-not [string]::IsNullOrWhiteSpace([string] $metadata.thumbnail)) { $thumbnailUrl = [string] $metadata.thumbnail }
        if (-not [string]::IsNullOrWhiteSpace([string] $metadata.duration_string)) { $duration = [string] $metadata.duration_string }
        if (-not [string]::IsNullOrWhiteSpace([string] $metadata.extractor_key)) { $provider = [string] $metadata.extractor_key }
        if (-not [string]::IsNullOrWhiteSpace([string] $metadata.webpage_url)) { $sourceUrl = [string] $metadata.webpage_url }
    }

    $thumbnailPath = Cache-HistoryThumbnail $thumbnailUrl
    $record = [PSCustomObject]@{
        Title = $title
        SourceUrl = $sourceUrl
        FilePath = $filePath
        ThumbnailUrl = $thumbnailUrl
        ThumbnailPath = $thumbnailPath
        Format = $format
        Duration = $duration
        Provider = $provider
        DownloadedAt = [DateTime]::Now.ToString('o')
    }

    $removed = @($script:history | Select-Object -Skip 99)
    foreach ($oldRecord in $removed) {
        if (-not [string]::IsNullOrWhiteSpace([string] $oldRecord.ThumbnailPath) -and (Test-Path -LiteralPath $oldRecord.ThumbnailPath -PathType Leaf)) {
            Remove-Item -LiteralPath $oldRecord.ThumbnailPath -Force -ErrorAction SilentlyContinue
        }
    }
    $script:history = @($record) + @($script:history | Select-Object -First 99)
    Save-History
}

function Get-DownloadMetadata([string] $text) {
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }

    $matches = [Regex]::Matches($text, '(?m)^DLR_HISTORY_JSON:(\{.*\})\s*$')
    if ($matches.Count -eq 0) {
        return $null
    }
    try {
        return $matches[$matches.Count - 1].Groups[1].Value | ConvertFrom-Json
    }
    catch {
        return $null
    }
}

function New-HistoryButton([string] $label, [string] $target, [bool] $isSource) {
    $button = [Windows.Controls.Button]::new()
    $button.Content = $label
    $button.Height = 32
    $button.Margin = [Windows.Thickness]::new(0, 0, 0, 7)
    $button.Style = $window.FindResource('GlassButton')
    $button.Foreground = New-Brush '#C79AFF'
    $button.Tag = [PSCustomObject]@{ Target = $target; IsSource = $isSource }
    $button.IsEnabled = -not [string]::IsNullOrWhiteSpace($target)
    $button.Add_Click({
        $action = $this.Tag
        $destination = [string] $action.Target
        if ([string]::IsNullOrWhiteSpace($destination)) {
            return
        }
        try {
            if ([bool] $action.IsSource) {
                [void] [Diagnostics.Process]::Start($destination)
                return
            }
            if (Test-Path -LiteralPath $destination -PathType Leaf) {
                [void] [Diagnostics.Process]::Start($destination)
                return
            }
            [void] [Windows.MessageBox]::Show(
                $window,
                'This downloaded file has been moved or deleted.',
                'File not found',
                [Windows.MessageBoxButton]::OK,
                [Windows.MessageBoxImage]::Information
            )
        }
        catch {
            [void] [Windows.MessageBox]::Show($window, $_.Exception.Message, 'Could not open item')
        }
    })
    return $button
}

function Render-History {
    $historyList.Children.Clear()
    $emptyHistoryPanel.Visibility = if ($script:history.Count -eq 0) { [Windows.Visibility]::Visible } else { [Windows.Visibility]::Collapsed }
    $clearHistoryButton.IsEnabled = ($script:history.Count -gt 0)

    foreach ($record in $script:history) {
        $card = [Windows.Controls.Border]::new()
        $card.Height = 108
        $card.Margin = [Windows.Thickness]::new(0, 0, 0, 10)
        $card.Padding = [Windows.Thickness]::new(10)
        $card.CornerRadius = [Windows.CornerRadius]::new(10)
        $card.Background = New-Brush '#B00B0D25'
        $card.BorderBrush = New-Brush '#4B2B2258'
        $card.BorderThickness = [Windows.Thickness]::new(1)

        $layout = [Windows.Controls.Grid]::new()
        foreach ($width in @('140', '16', '*', '16', '104')) {
            $column = [Windows.Controls.ColumnDefinition]::new()
            $column.Width = [Windows.GridLengthConverter]::new().ConvertFromString($width)
            $layout.ColumnDefinitions.Add($column)
        }

        $thumbnailShell = [Windows.Controls.Border]::new()
        $thumbnailShell.Width = 140
        $thumbnailShell.Height = 78
        $thumbnailShell.CornerRadius = [Windows.CornerRadius]::new(7)
        $thumbnailShell.Background = New-Brush '#15150842'
        $thumbnailShell.BorderBrush = New-Brush '#56331B7E'
        $thumbnailShell.BorderThickness = [Windows.Thickness]::new(1)
        $thumbnailGrid = [Windows.Controls.Grid]::new()
        $placeholder = [Windows.Controls.TextBlock]::new()
        $placeholder.Text = [char] 0xE91B
        $placeholder.FontFamily = [Windows.Media.FontFamily]::new('Segoe MDL2 Assets')
        $placeholder.FontSize = 24
        $placeholder.Foreground = New-Brush '#7950B9'
        $placeholder.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
        $placeholder.VerticalAlignment = [Windows.VerticalAlignment]::Center
        $thumbnailGrid.Children.Add($placeholder) | Out-Null

        $thumbnailSource = [string] $record.ThumbnailPath
        $bitmap = $null
        if (-not [string]::IsNullOrWhiteSpace($thumbnailSource) -and (Test-Path -LiteralPath $thumbnailSource -PathType Leaf)) {
            $bitmap = New-HistoryBitmap $thumbnailSource
        }
        if ($null -ne $bitmap) {
            $image = [Windows.Controls.Image]::new()
            $image.Source = $bitmap
            $image.Stretch = [Windows.Media.Stretch]::UniformToFill
            $thumbnailGrid.Children.Add($image) | Out-Null
        }
        $thumbnailShell.Child = $thumbnailGrid
        [Windows.Controls.Grid]::SetColumn($thumbnailShell, 0)
        $layout.Children.Add($thumbnailShell) | Out-Null

        $details = [Windows.Controls.StackPanel]::new()
        $details.VerticalAlignment = [Windows.VerticalAlignment]::Center
        $title = [Windows.Controls.TextBlock]::new()
        $title.Text = [string] $record.Title
        $title.FontSize = 13
        $title.FontWeight = [Windows.FontWeights]::SemiBold
        $title.Foreground = New-Brush '#F5F1FF'
        $title.TextTrimming = [Windows.TextTrimming]::CharacterEllipsis
        $details.Children.Add($title) | Out-Null

        $dateText = 'Downloaded'
        try { $dateText = ([DateTime]::Parse([string] $record.DownloadedAt)).ToLocalTime().ToString('MMM d, yyyy  h:mm tt') } catch {}
        $metaParts = @([string] $record.Format, [string] $record.Duration, [string] $record.Provider) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        $meta = [Windows.Controls.TextBlock]::new()
        $meta.Text = ($metaParts -join '  •  ') + '  •  ' + $dateText
        $meta.Margin = [Windows.Thickness]::new(0, 7, 0, 0)
        $meta.FontSize = 10
        $meta.Foreground = New-Brush '#A79CBF'
        $meta.TextTrimming = [Windows.TextTrimming]::CharacterEllipsis
        $details.Children.Add($meta) | Out-Null

        $pathText = [Windows.Controls.TextBlock]::new()
        $pathText.Text = if ([string]::IsNullOrWhiteSpace([string] $record.FilePath)) { [string] $record.SourceUrl } else { [string] $record.FilePath }
        $pathText.Margin = [Windows.Thickness]::new(0, 7, 0, 0)
        $pathText.FontSize = 10
        $pathText.Foreground = New-Brush '#746B88'
        $pathText.TextTrimming = [Windows.TextTrimming]::CharacterEllipsis
        $details.Children.Add($pathText) | Out-Null
        [Windows.Controls.Grid]::SetColumn($details, 2)
        $layout.Children.Add($details) | Out-Null

        $actions = [Windows.Controls.StackPanel]::new()
        $actions.VerticalAlignment = [Windows.VerticalAlignment]::Center
        $actions.Children.Add((New-HistoryButton 'Open file' ([string] $record.FilePath) $false)) | Out-Null
        $actions.Children.Add((New-HistoryButton 'View source' ([string] $record.SourceUrl) $true)) | Out-Null
        [Windows.Controls.Grid]::SetColumn($actions, 4)
        $layout.Children.Add($actions) | Out-Null

        $card.Child = $layout
        $historyList.Children.Add($card) | Out-Null
    }
}

function Show-HistoryPage([bool] $showHistory) {
    $downloadPage.Visibility = if ($showHistory) { [Windows.Visibility]::Collapsed } else { [Windows.Visibility]::Visible }
    $historyPage.Visibility = if ($showHistory) { [Windows.Visibility]::Visible } else { [Windows.Visibility]::Collapsed }
    $downloadStyle = if ($showHistory) { 'NavButton' } else { 'ActiveNavButton' }
    $historyStyle = if ($showHistory) { 'ActiveNavButton' } else { 'NavButton' }
    $downloadNavButton.Style = $window.FindResource($downloadStyle)
    $historyButton.Style = $window.FindResource($historyStyle)
    if ($showHistory) {
        Render-History
    }
}

Load-History

if ($env:DLR_UI_VALIDATE -eq 'history') {
    $script:history = @([PSCustomObject]@{
        Title = 'History preview'
        SourceUrl = 'https://example.com/video'
        FilePath = ''
        ThumbnailUrl = ''
        ThumbnailPath = ''
        Format = 'MP4 video'
        Duration = '2:05'
        Provider = 'Example'
        DownloadedAt = [DateTime]::Now.ToString('o')
    })
    Render-History
    return
}

function Set-Status([string] $text, [string] $color) {
    $statusText.Text = $text
    $statusDot.Fill = New-Brush $color
    $statusDot.Effect.Color = [Windows.Media.ColorConverter]::ConvertFromString($color)
}

function Set-Busy([bool] $busy) {
    $urlInput.IsEnabled = -not $busy
    $formatCombo.IsEnabled = -not $busy
    $outputInput.IsEnabled = -not $busy
    $browseButton.IsEnabled = -not $busy
    $downloadButton.IsEnabled = -not $busy
    $updateButton.IsEnabled = -not $busy

    if ($busy) {
        $qualityCombo.IsEnabled = $false
        $downloadProgress.Visibility = [Windows.Visibility]::Visible
    }
    else {
        $qualityCombo.IsEnabled = ($formatCombo.SelectedIndex -eq 1)
        $downloadProgress.Visibility = [Windows.Visibility]::Collapsed
    }
}

function Quote-NativeArgument([string] $value) {
    if ($null -eq $value -or $value.Length -eq 0) {
        return '""'
    }
    if ($value -notmatch '[\s"]') {
        return $value
    }

    $builder = [Text.StringBuilder]::new()
    [void] $builder.Append('"')
    $slashes = 0
    foreach ($character in $value.ToCharArray()) {
        if ($character -eq [char] 92) {
            $slashes++
            continue
        }
        if ($character -eq [char] 34) {
            [void] $builder.Append(('\' * (($slashes * 2) + 1)))
            [void] $builder.Append('"')
            $slashes = 0
            continue
        }
        if ($slashes -gt 0) {
            [void] $builder.Append(('\' * $slashes))
            $slashes = 0
        }
        [void] $builder.Append($character)
    }
    if ($slashes -gt 0) {
        [void] $builder.Append(('\' * ($slashes * 2)))
    }
    [void] $builder.Append('"')
    return $builder.ToString()
}

function Get-UsefulOutput([string] $text) {
    if ([string]::IsNullOrWhiteSpace($text)) {
        return ''
    }
    $lines = @($text -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -notmatch '^DLR_HISTORY_JSON:' })
    if ($lines.Count -eq 0) {
        return ''
    }

    if ($text -match 'HTTP Error 403:\s*Forbidden') {
        if ($text -match 'warning: could not update yt-dlp') {
            return 'DLR could not update yt-dlp, then YouTube refused the media request (HTTP 403). Check your connection or firewall and retry.'
        }
        return 'YouTube refused the media request (HTTP 403). DLR checked for a current yt-dlp before downloading. Retry once; if it still fails, the video may require sign-in or be restricted.'
    }

    $important = @($lines | Where-Object {
        $_ -match '^(ERROR|WARNING):' -or
        ($_ -match '^error:' -and $_ -notmatch 'yt-dlp failed: exit status')
    })
    if ($important.Count -gt 0) {
        $message = ($important | Select-Object -Last 4) -join "`n"
    }
    else {
        $message = ($lines | Where-Object { $_ -notmatch '^error: yt-dlp failed: exit status' } | Select-Object -Last 4) -join "`n"
    }
    if ($message.Length -gt 520) {
        return $message.Substring(0, 517) + '...'
    }
    return $message
}

function ConvertTo-DLRVersion([string] $value) {
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $null
    }
    $normalized = $value.Trim().TrimStart('v').Split('-')[0]
    try {
        return [Version] $normalized
    }
    catch {
        return $null
    }
}

function Install-DLRUpdate($release) {
    $packageName = 'dlr-windows-amd64.zip'
    $packageAsset = @($release.assets) | Where-Object { $_.name -eq $packageName } | Select-Object -First 1
    $checksumAsset = @($release.assets) | Where-Object { $_.name -eq 'SHA256SUMS.txt' } | Select-Object -First 1
    if ($null -eq $packageAsset -or $null -eq $checksumAsset) {
        throw 'The latest release does not contain the Windows package and checksum file.'
    }

    $updateDirectory = Join-Path ([IO.Path]::GetTempPath()) ('dlr-update-' + [Guid]::NewGuid().ToString('N'))
    [IO.Directory]::CreateDirectory($updateDirectory) | Out-Null

    $updaterPath = Join-Path $updateDirectory 'install-update.ps1'
    $updaterScript = @'
param(
    [int] $RunningProcessId,
    [string] $PackageUrl,
    [string] $ChecksumUrl,
    [string] $UpdateDirectory,
    [string] $Destination,
    [string] $Executable,
    [string] $InstalledVersion
)
$ErrorActionPreference = 'Stop'
try {
    try {
        [Diagnostics.Process]::GetProcessById($RunningProcessId).WaitForExit()
    }
    catch {
    }
    Start-Sleep -Milliseconds 350

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $packagePath = Join-Path $UpdateDirectory 'dlr-windows-amd64.zip'
    $checksumPath = Join-Path $UpdateDirectory 'SHA256SUMS.txt'
    $extractPath = Join-Path $UpdateDirectory 'package'
    $client = [Net.WebClient]::new()
    $client.Headers['User-Agent'] = 'DLR-Updater/' + $InstalledVersion
    try {
        $client.DownloadFile($PackageUrl, $packagePath)
        $client.DownloadFile($ChecksumUrl, $checksumPath)
    }
    finally {
        $client.Dispose()
    }

    $checksumText = [IO.File]::ReadAllText($checksumPath)
    $match = [Regex]::Match($checksumText, '(?im)^([a-f0-9]{64})\s+\*?\.?/?dlr-windows-amd64\.zip\s*$')
    if (-not $match.Success) {
        throw 'The release checksum file does not list the Windows package.'
    }
    $expectedHash = $match.Groups[1].Value.ToUpperInvariant()
    $actualHash = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualHash -ne $expectedHash) {
        throw 'The downloaded update failed SHA-256 verification and was not installed.'
    }

    Expand-Archive -LiteralPath $packagePath -DestinationPath $extractPath -Force
    $source = Join-Path $extractPath 'dlr-windows-amd64'
    if (-not (Test-Path -LiteralPath (Join-Path $source $Executable) -PathType Leaf)) {
        throw 'The downloaded update has an unexpected folder structure.'
    }
    Get-ChildItem -LiteralPath $source -Force | Copy-Item -Destination $Destination -Recurse -Force
    Start-Process -FilePath (Join-Path $Destination $Executable) -WorkingDirectory $Destination
}
catch {
    Add-Type -AssemblyName PresentationFramework
    [void] [Windows.MessageBox]::Show(
        "DLR could not install the update.`n`n$($_.Exception.Message)",
        'DLR update failed',
        [Windows.MessageBoxButton]::OK,
        [Windows.MessageBoxImage]::Error
    )
}
'@
    [IO.File]::WriteAllText($updaterPath, $updaterScript, [Text.UTF8Encoding]::new($false))

    $updaterArguments = @(
        '-NoLogo', '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass',
        '-File', $updaterPath,
        '-RunningProcessId', $appProcessId.ToString(),
        '-PackageUrl', ([string] $packageAsset.browser_download_url),
        '-ChecksumUrl', ([string] $checksumAsset.browser_download_url),
        '-UpdateDirectory', $updateDirectory,
        '-Destination', $appDirectory,
        '-Executable', 'dlr-gui.exe',
        '-InstalledVersion', $appVersion
    )
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = 'powershell.exe'
    $startInfo.Arguments = ($updaterArguments | ForEach-Object { Quote-NativeArgument ([string] $_) }) -join ' '
    $startInfo.WorkingDirectory = $appDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    if (-not [Diagnostics.Process]::Start($startInfo)) {
        throw 'Windows could not start the update installer.'
    }
    $window.Close()
}

$script:updateClient = $null
$script:updateCheckTask = $null
$script:updateCheckManual = $false

$updateTimer = [Windows.Threading.DispatcherTimer]::new()
$updateTimer.Interval = [TimeSpan]::FromMilliseconds(250)
$updateTimer.Add_Tick({
    if ($null -eq $script:updateCheckTask -or -not $script:updateCheckTask.IsCompleted) {
        return
    }

    $updateTimer.Stop()
    $task = $script:updateCheckTask
    $wasManual = $script:updateCheckManual
    $script:updateCheckTask = $null
    $script:updateCheckManual = $false
    if ($null -ne $script:updateClient) {
        $script:updateClient.Dispose()
        $script:updateClient = $null
    }

    if ($task.IsCanceled -or $task.IsFaulted) {
        if ($wasManual) {
            Set-Status 'Offline.' '#FFB86B'
            [void] [Windows.MessageBox]::Show(
                $window,
                'DLR could not check GitHub for updates. Check your internet connection and try again.',
                'Update check failed',
                [Windows.MessageBoxButton]::OK,
                [Windows.MessageBoxImage]::Warning
            )
        }
        return
    }

    try {
        $release = $task.Result | ConvertFrom-Json
        $currentVersion = ConvertTo-DLRVersion $appVersion
        $latestVersion = ConvertTo-DLRVersion ([string] $release.tag_name)
        if ($null -eq $currentVersion -or $null -eq $latestVersion) {
            if ($wasManual) {
                throw 'DLR could not compare the installed and latest version numbers.'
            }
            return
        }
        if ($latestVersion -le $currentVersion) {
            if ($wasManual) {
                Set-Status 'Ready.' '#51D68B'
                [void] [Windows.MessageBox]::Show(
                    $window,
                    "DLR $appVersion is already the latest version.",
                    'DLR is up to date',
                    [Windows.MessageBoxButton]::OK,
                    [Windows.MessageBoxImage]::Information
                )
            }
            return
        }

        $answer = [Windows.MessageBox]::Show(
            $window,
            "DLR $($release.tag_name) is available. DLR will close, install the verified GitHub release, and restart automatically. Continue?",
            'DLR update available',
            [Windows.MessageBoxButton]::YesNo,
            [Windows.MessageBoxImage]::Information
        )
        if ($answer -ne [Windows.MessageBoxResult]::Yes) {
            Set-Status 'Ready.' '#51D68B'
            return
        }

        Set-Status 'Updating...' '#B7ADFF'
        $activityIcon.Text = [char] 0xE895
        $activityTitle.Text = 'Installing update'
        $activityText.Text = 'Downloading and verifying the latest GitHub release.'
        Install-DLRUpdate $release
    }
    catch {
        Set-Status 'Update failed.' '#FF7B91'
        $activityIcon.Text = '!'
        $activityTitle.Text = 'Could not install update'
        $activityText.Text = $_.Exception.Message
        [void] [Windows.MessageBox]::Show(
            $window,
            $_.Exception.Message,
            'DLR update failed',
            [Windows.MessageBoxButton]::OK,
            [Windows.MessageBoxImage]::Error
        )
    }
})

function Start-DLRUpdateCheck([bool] $manual) {
    if ($null -ne $script:updateCheckTask) {
        if ($manual) {
            $script:updateCheckManual = $true
            Set-Status 'Checking...' '#B7ADFF'
        }
        return
    }

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $script:updateCheckManual = $manual
        $script:updateClient = [Net.WebClient]::new()
        $script:updateClient.Headers['User-Agent'] = 'DLR-Updater/' + $appVersion
        $releaseUri = [Uri] 'https://api.github.com/repos/a3ylf/downloader/releases/latest'
        $script:updateCheckTask = $script:updateClient.DownloadStringTaskAsync($releaseUri)
        if ($manual) {
            Set-Status 'Checking...' '#B7ADFF'
        }
        $updateTimer.Start()
    }
    catch {
        if ($null -ne $script:updateClient) {
            $script:updateClient.Dispose()
            $script:updateClient = $null
        }
        $script:updateCheckTask = $null
        if ($manual) {
            [void] [Windows.MessageBox]::Show($window, $_.Exception.Message, 'Update check failed')
        }
    }
}

$urlInput.Add_TextChanged({
    if ([string]::IsNullOrWhiteSpace($urlInput.Text)) {
        $urlPlaceholder.Visibility = [Windows.Visibility]::Visible
    }
    else {
        $urlPlaceholder.Visibility = [Windows.Visibility]::Collapsed
    }
})

$titleBar.Add_MouseLeftButtonDown({
    param($sender, $eventArgs)
    if ($eventArgs.ClickCount -eq 2) {
        if ($window.WindowState -eq [Windows.WindowState]::Maximized) {
            $window.WindowState = [Windows.WindowState]::Normal
        }
        else {
            $window.WindowState = [Windows.WindowState]::Maximized
        }
        return
    }
    try {
        $window.DragMove()
    }
    catch {
    }
})

$minimizeButton.Add_Click({
    $window.WindowState = [Windows.WindowState]::Minimized
})

$maximizeButton.Add_Click({
    if ($window.WindowState -eq [Windows.WindowState]::Maximized) {
        $window.WindowState = [Windows.WindowState]::Normal
    }
    else {
        $window.WindowState = [Windows.WindowState]::Maximized
    }
})

$closeButton.Add_Click({
    $window.Close()
})

$formatCombo.Add_SelectionChanged({
    $qualityCombo.IsEnabled = ($formatCombo.SelectedIndex -eq 1)
    $qualityCombo.Opacity = if ($qualityCombo.IsEnabled) { 1 } else { 0.48 }
})

$updateButton.Add_Click({
    Start-DLRUpdateCheck $true
})

$downloadNavButton.Add_Click({
    Show-HistoryPage $false
})

$historyButton.Add_Click({
    Show-HistoryPage $true
})

$clearHistoryButton.Add_Click({
    if ($script:history.Count -eq 0) {
        return
    }
    $answer = [Windows.MessageBox]::Show(
        $window,
        'Remove every item from download history? Downloaded files will not be deleted.',
        'Clear download history',
        [Windows.MessageBoxButton]::YesNo,
        [Windows.MessageBoxImage]::Question
    )
    if ($answer -ne [Windows.MessageBoxResult]::Yes) {
        return
    }
    foreach ($record in $script:history) {
        if (-not [string]::IsNullOrWhiteSpace([string] $record.ThumbnailPath) -and (Test-Path -LiteralPath $record.ThumbnailPath -PathType Leaf)) {
            Remove-Item -LiteralPath $record.ThumbnailPath -Force -ErrorAction SilentlyContinue
        }
    }
    $script:history = @()
    Save-History
    Render-History
})

$browseButton.Add_Click({
    $dialog = [Windows.Forms.FolderBrowserDialog]::new()
    $dialog.Description = 'Choose where downloaded files will be saved'
    $dialog.ShowNewFolderButton = $true
    if (Test-Path -LiteralPath $outputInput.Text -PathType Container) {
        $dialog.SelectedPath = $outputInput.Text
    }
    if ($dialog.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
        $outputInput.Text = $dialog.SelectedPath
    }
    $dialog.Dispose()
})

$openFolderButton.Add_Click({
    $folder = $outputInput.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($folder)) {
        return
    }
    if (-not (Test-Path -LiteralPath $folder -PathType Container)) {
        [void] [Windows.MessageBox]::Show(
            $window,
            'That output folder does not exist yet.',
            'DLR Downloader',
            [Windows.MessageBoxButton]::OK,
            [Windows.MessageBoxImage]::Information
        )
        return
    }
    [void] [Diagnostics.Process]::Start('explorer.exe', (Quote-NativeArgument $folder))
})

$script:downloadProcess = $null
$script:stdoutTask = $null
$script:stderrTask = $null
$script:activeDownloadLink = ''
$script:activeDownloadFormat = ''

$downloadTimer = [Windows.Threading.DispatcherTimer]::new()
$downloadTimer.Interval = [TimeSpan]::FromMilliseconds(350)
$downloadTimer.Add_Tick({
    if ($null -eq $script:downloadProcess) {
        return
    }

    $script:downloadProcess.Refresh()
    if (-not $script:downloadProcess.HasExited) {
        return
    }

    $downloadTimer.Stop()
    $exitCode = $script:downloadProcess.ExitCode
    $standardOutput = $script:stdoutTask.Result
    $standardError = $script:stderrTask.Result
    $combinedOutput = ($standardOutput + "`n" + $standardError).Trim()
    $downloadMetadata = Get-DownloadMetadata $combinedOutput
    $usefulOutput = Get-UsefulOutput $combinedOutput

    Set-Busy $false
    if ($exitCode -eq 0) {
        Set-Status 'Complete.' '#68D391'
        $activityIcon.Text = [char] 0x2713
        $activityTitle.Text = 'Download complete'
        $activityText.Text = "Your file was saved to $($outputInput.Text)."
        try {
            Add-HistoryRecord $downloadMetadata $script:activeDownloadLink $script:activeDownloadFormat
            if ($historyPage.Visibility -eq [Windows.Visibility]::Visible) {
                Render-History
            }
        }
        catch {
            # History is a convenience; a storage or thumbnail error must not
            # turn a successfully downloaded file into a failed download.
        }
    }
    else {
        Set-Status 'Failed.' '#FF7B91'
        $activityIcon.Text = '!'
        $activityTitle.Text = 'Download failed'
        if ([string]::IsNullOrWhiteSpace($usefulOutput)) {
            $activityText.Text = "dlr.exe exited with code $exitCode."
        }
        else {
            $activityText.Text = $usefulOutput
        }
    }

    $script:downloadProcess.Dispose()
    $script:downloadProcess = $null
    $script:stdoutTask = $null
    $script:stderrTask = $null
})

$downloadButton.Add_Click({
    $link = $urlInput.Text.Trim()
    $outputFolder = $outputInput.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($link)) {
        [void] [Windows.MessageBox]::Show(
            $window,
            'Paste a video or post link first.',
            'Missing link',
            [Windows.MessageBoxButton]::OK,
            [Windows.MessageBoxImage]::Information
        )
        $urlInput.Focus()
        return
    }
    if ([string]::IsNullOrWhiteSpace($outputFolder)) {
        [void] [Windows.MessageBox]::Show(
            $window,
            'Choose an output folder first.',
            'Missing folder',
            [Windows.MessageBoxButton]::OK,
            [Windows.MessageBoxImage]::Information
        )
        return
    }

    $backend = Join-Path $appDirectory 'dlr.exe'
    if (-not (Test-Path -LiteralPath $backend -PathType Leaf)) {
        [void] [Windows.MessageBox]::Show(
            $window,
            'dlr.exe must be in the same folder as dlr-gui.exe. Extract the complete Windows ZIP before running the app.',
            'DLR backend not found',
            [Windows.MessageBoxButton]::OK,
            [Windows.MessageBoxImage]::Error
        )
        return
    }

    try {
        [IO.Directory]::CreateDirectory($outputFolder) | Out-Null

        $downloadArguments = @('--out', $outputFolder, '--history-json')
        if ($formatCombo.SelectedIndex -eq 0) {
            $downloadArguments += '--mp3'
        }
        else {
            $qualityValues = @(0, 1080, 720, 480)
            $height = $qualityValues[$qualityCombo.SelectedIndex]
            if ($height -gt 0) {
                $downloadArguments += @('--quality', $height.ToString())
            }
        }
        $downloadArguments += $link

        $script:activeDownloadLink = $link
        $script:activeDownloadFormat = if ($formatCombo.SelectedIndex -eq 0) { 'MP3 audio' } else { 'MP4 video' }

        $startInfo = [Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $backend
        $startInfo.Arguments = ($downloadArguments | ForEach-Object { Quote-NativeArgument ([string] $_) }) -join ' '
        $startInfo.WorkingDirectory = $appDirectory
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true

        $script:downloadProcess = [Diagnostics.Process]::new()
        $script:downloadProcess.StartInfo = $startInfo
        if (-not $script:downloadProcess.Start()) {
            throw 'Windows could not start dlr.exe.'
        }

        $script:stdoutTask = $script:downloadProcess.StandardOutput.ReadToEndAsync()
        $script:stderrTask = $script:downloadProcess.StandardError.ReadToEndAsync()

        Set-Busy $true
        Set-Status 'Downloading...' '#B7ADFF'
        $activityIcon.Text = [char] 0x2193
        $activityTitle.Text = 'Download in progress'
        $activityText.Text = 'DLR is fetching and preparing your file. Keep this window open.'
        $downloadTimer.Start()
    }
    catch {
        if ($null -ne $script:downloadProcess) {
            $script:downloadProcess.Dispose()
            $script:downloadProcess = $null
        }
        Set-Busy $false
        Set-Status 'Failed.' '#FF7B91'
        $activityIcon.Text = '!'
        $activityTitle.Text = 'Could not start download'
        $activityText.Text = $_.Exception.Message
    }
})

$window.Add_Closed({
    $downloadTimer.Stop()
    $updateTimer.Stop()
    if ($null -ne $script:updateClient) {
        $script:updateClient.Dispose()
        $script:updateClient = $null
    }
    if ($null -ne $script:downloadProcess -and -not $script:downloadProcess.HasExited) {
        try {
            $script:downloadProcess.Kill()
        }
        catch {
        }
    }
})

$window.Add_ContentRendered({
    $urlInput.Focus()
    Start-DLRUpdateCheck $false
})

[void] $window.ShowDialog()
