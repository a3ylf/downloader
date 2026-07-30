$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="DLR Downloader"
    Width="700"
    Height="650"
    MinWidth="620"
    MinHeight="610"
    WindowStartupLocation="CenterScreen"
    WindowStyle="None"
    ResizeMode="CanResizeWithGrip"
    AllowsTransparency="True"
    Background="Transparent"
    FontFamily="Segoe UI Variable Text, Segoe UI"
    Foreground="#F7F9FF"
    TextOptions.TextFormattingMode="Display"
    UseLayoutRounding="True">

    <Window.Resources>
        <SolidColorBrush x:Key="TextPrimary" Color="#F7F9FF"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#C9D1E8"/>
        <SolidColorBrush x:Key="ControlFill" Color="#1FFFFFFF"/>
        <SolidColorBrush x:Key="ControlStroke" Color="#45FFFFFF"/>
        <SolidColorBrush x:Key="ControlHover" Color="#32FFFFFF"/>
        <SolidColorBrush x:Key="AccentFill" Color="#7C6FF2"/>
        <SolidColorBrush x:Key="AccentHover" Color="#9388FF"/>

        <Style x:Key="GlassButton" TargetType="Button">
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="Background" Value="{StaticResource ControlFill}"/>
            <Setter Property="BorderBrush" Value="{StaticResource ControlStroke}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="14,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border
                            x:Name="ButtonShell"
                            CornerRadius="9"
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
                                <Setter TargetName="ButtonShell" Property="BorderBrush" Value="#6AFFFFFF"/>
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
            <Setter Property="BorderBrush" Value="#8FC9C4FF"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Effect">
                <Setter.Value>
                    <DropShadowEffect Color="#745FFF" BlurRadius="18" ShadowDepth="0" Opacity="0.55"/>
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
            <Setter Property="FontSize" Value="14"/>
        </Style>

        <Style TargetType="ComboBoxItem">
            <Setter Property="Foreground" Value="{StaticResource TextPrimary}"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Padding" Value="12,8"/>
            <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBoxItem">
                        <Border x:Name="ItemShell" Background="{TemplateBinding Background}" CornerRadius="6" Margin="4,2">
                            <ContentPresenter Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsHighlighted" Value="True">
                                <Setter TargetName="ItemShell" Property="Background" Value="#486F7DCE"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="ItemShell" Property="Background" Value="#686E63D8"/>
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
            <Setter Property="Padding" Value="12,0"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <Border
                                x:Name="ComboShell"
                                CornerRadius="9"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}">
                                <Grid>
                                    <ContentPresenter
                                        Margin="13,0,38,0"
                                        VerticalAlignment="Center"
                                        HorizontalAlignment="Left"
                                        Content="{TemplateBinding SelectionBoxItem}"/>
                                    <Path
                                        Data="M 0 0 L 4 4 L 8 0"
                                        Stroke="#E8ECFF"
                                        StrokeThickness="1.4"
                                        HorizontalAlignment="Right"
                                        VerticalAlignment="Center"
                                        Margin="0,0,14,0"/>
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
                                    CornerRadius="9"
                                    Background="#F0273158"
                                    BorderBrush="#62FFFFFF"
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
                                <Setter TargetName="ComboShell" Property="BorderBrush" Value="#6AFFFFFF"/>
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
            <Setter Property="Height" Value="3"/>
            <Setter Property="Background" Value="#24FFFFFF"/>
            <Setter Property="Foreground" Value="#B7ADFF"/>
            <Setter Property="BorderThickness" Value="0"/>
        </Style>
    </Window.Resources>

    <Grid Margin="16">
        <Border
            Name="WindowShell"
            CornerRadius="18"
            BorderBrush="#70FFFFFF"
            BorderThickness="1"
            SnapsToDevicePixels="True">
            <Border.Effect>
                <DropShadowEffect Color="#050817" BlurRadius="38" ShadowDepth="12" Opacity="0.92"/>
            </Border.Effect>
            <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                    <GradientStop Color="#F018203B" Offset="0"/>
                    <GradientStop Color="#EE454F82" Offset="0.48"/>
                    <GradientStop Color="#F027426D" Offset="1"/>
                </LinearGradientBrush>
            </Border.Background>

            <Grid ClipToBounds="True">
                <Ellipse Width="440" Height="300" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="-120,-135,0,0" Fill="#5F8D7BFF">
                    <Ellipse.Effect>
                        <BlurEffect Radius="82"/>
                    </Ellipse.Effect>
                </Ellipse>
                <Ellipse Width="370" Height="330" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,-120,-150" Fill="#556AB9FF">
                    <Ellipse.Effect>
                        <BlurEffect Radius="92"/>
                    </Ellipse.Effect>
                </Ellipse>
                <Rectangle Fill="#16000000"/>

                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="56"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Grid Name="TitleBar" Grid.Row="0" Background="#08000000" Margin="1,1,1,0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="18,0,0,0">
                            <Border Width="30" Height="30" CornerRadius="8" Background="#24FFFFFF" BorderBrush="#48FFFFFF" BorderThickness="1">
                                <TextBlock Text="&#xE896;" FontFamily="Segoe MDL2 Assets" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <TextBlock Name="TitleText" Text="DLR Downloader" Margin="12,0,0,0" FontSize="14" FontWeight="SemiBold" VerticalAlignment="Center"/>
                        </StackPanel>

                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" Margin="0,0,12,0">
                            <Button Name="MinimizeButton" Content="&#xE921;" FontFamily="Segoe MDL2 Assets" Style="{StaticResource WindowButton}"/>
                            <Button Name="MaximizeButton" Content="&#xE922;" FontFamily="Segoe MDL2 Assets" Style="{StaticResource WindowButton}"/>
                            <Button Name="CloseButton" Content="&#xE8BB;" FontFamily="Segoe MDL2 Assets" Style="{StaticResource WindowButton}"/>
                        </StackPanel>
                    </Grid>

                    <Grid Grid.Row="1" Margin="28,14,28,26">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="20"/>
                            <RowDefinition Height="46"/>
                            <RowDefinition Height="15"/>
                            <RowDefinition Height="20"/>
                            <RowDefinition Height="46"/>
                            <RowDefinition Height="17"/>
                            <RowDefinition Height="20"/>
                            <RowDefinition Height="46"/>
                            <RowDefinition Height="21"/>
                            <RowDefinition Height="50"/>
                            <RowDefinition Height="22"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <TextBlock Grid.Row="0" Text="Video or post link" FontSize="12" FontWeight="SemiBold" Foreground="{StaticResource TextPrimary}"/>
                        <Border Grid.Row="1" CornerRadius="9" Background="{StaticResource ControlFill}" BorderBrush="{StaticResource ControlStroke}" BorderThickness="1">
                            <Grid>
                                <TextBox
                                    Name="URLInput"
                                    Margin="13,0"
                                    VerticalContentAlignment="Center"
                                    Background="Transparent"
                                    BorderThickness="0"
                                    Foreground="{StaticResource TextPrimary}"
                                    CaretBrush="#FFFFFF"
                                    FontSize="13"/>
                                <TextBlock
                                    Name="URLPlaceholder"
                                    Text="https://example.com/video"
                                    Margin="14,0"
                                    VerticalAlignment="Center"
                                    Foreground="#88D5DBEC"
                                    FontSize="13"
                                    IsHitTestVisible="False"/>
                            </Grid>
                        </Border>

                        <Grid Grid.Row="3">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="18"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="Download as" FontSize="12" FontWeight="SemiBold"/>
                            <TextBlock Grid.Column="2" Text="Maximum quality" FontSize="12" FontWeight="SemiBold"/>
                        </Grid>

                        <Grid Grid.Row="4">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="18"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <ComboBox Name="FormatCombo" Style="{StaticResource GlassCombo}" SelectedIndex="0">
                                <ComboBoxItem Content="Video (MP4)"/>
                                <ComboBoxItem Content="Audio (MP3)"/>
                            </ComboBox>
                            <ComboBox Name="QualityCombo" Grid.Column="2" Style="{StaticResource GlassCombo}" SelectedIndex="0">
                                <ComboBoxItem Content="Best available"/>
                                <ComboBoxItem Content="1080p"/>
                                <ComboBoxItem Content="720p"/>
                                <ComboBoxItem Content="480p"/>
                            </ComboBox>
                        </Grid>

                        <TextBlock Grid.Row="6" Text="Save to" FontSize="12" FontWeight="SemiBold"/>
                        <Grid Grid.Row="7">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="12"/>
                                <ColumnDefinition Width="108"/>
                            </Grid.ColumnDefinitions>
                            <Border CornerRadius="9" Background="{StaticResource ControlFill}" BorderBrush="{StaticResource ControlStroke}" BorderThickness="1">
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="38"/>
                                        <ColumnDefinition Width="*"/>
                                    </Grid.ColumnDefinitions>
                                    <TextBlock Text="&#xE8B7;" FontFamily="Segoe MDL2 Assets" FontSize="15" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#DCE3FA"/>
                                    <TextBox
                                        Name="OutputInput"
                                        Grid.Column="1"
                                        Margin="0,0,12,0"
                                        VerticalContentAlignment="Center"
                                        Background="Transparent"
                                        BorderThickness="0"
                                        Foreground="{StaticResource TextPrimary}"
                                        CaretBrush="#FFFFFF"
                                        FontSize="13"/>
                                </Grid>
                            </Border>
                            <Button Name="BrowseButton" Grid.Column="2" Content="Browse" Style="{StaticResource GlassButton}"/>
                        </Grid>

                        <Grid Grid.Row="9">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="1.04*"/>
                                <ColumnDefinition Width="12"/>
                                <ColumnDefinition Width="1.08*"/>
                                <ColumnDefinition Width="12"/>
                                <ColumnDefinition Width="1.05*"/>
                            </Grid.ColumnDefinitions>

                            <Button Name="DownloadButton" Style="{StaticResource AccentButton}">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="&#xE896;" FontFamily="Segoe MDL2 Assets" FontSize="14" Margin="0,0,8,0"/>
                                    <TextBlock Text="Download" VerticalAlignment="Center"/>
                                </StackPanel>
                            </Button>

                            <Button Name="OpenFolderButton" Grid.Column="2" Style="{StaticResource GlassButton}">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="&#xE8B7;" FontFamily="Segoe MDL2 Assets" FontSize="14" Margin="0,0,8,0"/>
                                    <TextBlock Text="Open folder" VerticalAlignment="Center"/>
                                </StackPanel>
                            </Button>

                            <Border Name="StatusPill" Grid.Column="4" CornerRadius="9" Background="#1DFFFFFF" BorderBrush="#3BFFFFFF" BorderThickness="1">
                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
                                    <Ellipse Name="StatusDot" Width="8" Height="8" Fill="#68D391" Margin="0,0,9,0">
                                        <Ellipse.Effect>
                                            <DropShadowEffect Color="#68D391" BlurRadius="8" ShadowDepth="0" Opacity="0.9"/>
                                        </Ellipse.Effect>
                                    </Ellipse>
                                    <TextBlock Name="StatusText" Text="Ready." FontSize="13" Foreground="{StaticResource TextSecondary}"/>
                                </StackPanel>
                            </Border>
                        </Grid>

                        <Border
                            Name="ActivityCard"
                            Grid.Row="11"
                            MinHeight="130"
                            CornerRadius="12"
                            Background="#16FFFFFF"
                            BorderBrush="#32FFFFFF"
                            BorderThickness="1">
                            <Grid Margin="22,18">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="68"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="54" Height="54" CornerRadius="27" Background="#12FFFFFF" BorderBrush="#4AFFFFFF" BorderThickness="1" HorizontalAlignment="Left" VerticalAlignment="Center">
                                    <TextBlock Name="ActivityIcon" Text="&#x2193;" FontSize="29" FontWeight="Light" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#ECF0FF"/>
                                </Border>
                                <Grid Grid.Column="1" Margin="10,0,0,0">
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="Auto"/>
                                        <RowDefinition Height="*"/>
                                        <RowDefinition Height="Auto"/>
                                    </Grid.RowDefinitions>
                                    <TextBlock Name="ActivityTitle" Text="Ready to download" FontSize="14" FontWeight="SemiBold" Margin="0,1,0,7"/>
                                    <TextBlock
                                        Name="ActivityText"
                                        Grid.Row="1"
                                        Text="Paste a link, choose the options, and click Download."
                                        TextWrapping="Wrap"
                                        FontSize="13"
                                        LineHeight="20"
                                        Foreground="{StaticResource TextSecondary}"
                                        VerticalAlignment="Top"/>
                                    <ProgressBar
                                        Name="DownloadProgress"
                                        Grid.Row="2"
                                        Margin="0,10,0,0"
                                        Style="{StaticResource SlimProgress}"
                                        IsIndeterminate="True"
                                        Visibility="Collapsed"/>
                                </Grid>
                            </Grid>
                        </Border>
                    </Grid>
                </Grid>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

$window = [Windows.Markup.XamlReader]::Parse($xaml)

function Find-Control([string] $name) {
    return $window.FindName($name)
}

$titleBar = Find-Control 'TitleBar'
$titleText = Find-Control 'TitleText'
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

$appDirectory = $env:DLR_APP_DIR
$appVersion = $env:DLR_APP_VERSION
if ([string]::IsNullOrWhiteSpace($appDirectory)) {
    $appDirectory = [AppDomain]::CurrentDomain.BaseDirectory
}
if ([string]::IsNullOrWhiteSpace($appVersion)) {
    $appVersion = 'dev'
}

$titleText.Text = "DLR Downloader $appVersion"
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

    if ($busy) {
        $qualityCombo.IsEnabled = $false
        $downloadProgress.Visibility = [Windows.Visibility]::Visible
    }
    else {
        $qualityCombo.IsEnabled = ($formatCombo.SelectedIndex -eq 0)
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
    $lines = @($text -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    if ($lines.Count -eq 0) {
        return ''
    }
    $message = ($lines | Select-Object -Last 2) -join "`n"
    if ($message.Length -gt 260) {
        return $message.Substring(0, 257) + '...'
    }
    return $message
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
    $qualityCombo.IsEnabled = ($formatCombo.SelectedIndex -eq 0)
    $qualityCombo.Opacity = if ($qualityCombo.IsEnabled) { 1 } else { 0.48 }
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
    $usefulOutput = Get-UsefulOutput $combinedOutput

    Set-Busy $false
    if ($exitCode -eq 0) {
        Set-Status 'Complete.' '#68D391'
        $activityIcon.Text = [char] 0x2713
        $activityTitle.Text = 'Download complete'
        $activityText.Text = "Your file was saved to $($outputInput.Text)."
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

        $downloadArguments = @('--out', $outputFolder)
        if ($formatCombo.SelectedIndex -eq 1) {
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
})

[void] $window.ShowDialog()
