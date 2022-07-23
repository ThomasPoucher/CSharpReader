
# function Get-CSharpFile {
#     param (
#         [string]$FilePath
#     )
#     $content = Get-Content -Path $FilePath | Out-String
#     $content = Remove-CSharpComments -TextContent $content
#     return $content
# }

function Get-CSharpMultiLineComments {
    param (
        [string]$TextContent
    )
    $commentMatches = [regex]::Matches($TextContent, "\/\*[\s\S]+?\*\/+?")
    return $commentMatches
}

function Get-CSharpSingleLineComments {
    param (
        [string]$TextContent
    )
    $commentMatches = [regex]::Matches($TextContent, "(\A|[^\/^\`"^']{1})(\/\/.*?[\n\r])")
    return $commentMatches
}

function Remove-CSharpComments {
    param (
        [string]$TextContent
    )
    $iterator = $true
    [string]$newContent = $TextContent
    while ($iterator) {
        $multiLineComments = Get-CSharpMultiLineComments -TextContent $newContent
        $firstMultiLineComment = $multiLineComments | Sort-Object -Property { $_.Index } | Select-Object -First 1
        $singleLineLineComments = Get-CSharpSingleLineComments -TextContent $newContent
        $firstSingleLineComment = $singleLineLineComments | Sort-Object -Property { $_.Index } | Select-Object -First 1
        if ($null -eq $firstSingleLineComment -and $null -eq $firstMultiLineComment) {
            $iterator = $false
        }
        elseif ($null -ne $firstSingleLineComment -and $null -ne $firstMultiLineComment) {
            if ($firstMultiLineComment[0].Groups[0].Index -lt $firstSingleLineComment[0].Groups[2].Index) {
                $startIndex = $firstMultiLineComment[0].Groups[0].Index
                $endIndex = $firstMultiLineComment.Groups[0].Length
                $newContent = $newContent.Remove($startIndex, $endIndex)
            }
            else {
                $startIndex = $firstSingleLineComment[0].Groups[2].Index
                $endIndex = $firstSingleLineComment.Groups[2].Length
                $newContent = $newContent.Remove($startIndex, $endIndex)
            }
        }
        elseif ($null -eq $firstSingleLineComment) {
            $startIndex = $firstMultiLineComment[0].Groups[0].Index
            $endIndex = $firstMultiLineComment.Groups[0].Length
            $newContent = $newContent.Remove($startIndex, $endIndex)
        }
        elseif ($null -eq $firstMultiLineComment) {
            $startIndex = $firstSingleLineComment[0].Groups[2].Index
            $endIndex = $firstSingleLineComment.Groups[2].Length
            $newContent = $newContent.Remove($startIndex, $endIndex)
        }
        
    }
    return $newContent
 
}

function Get-CSharpFields{
    param (
        [string]$TextContent
    )
    $fieldMatches = [regex]::Matches($TextContent, "(?<DataType>[\w]*)[?]{0,1}[ ]*(?<PropertyName>[\w]{1,})[ ]*(?={|=|,)")
    foreach($field in $fieldMatches){
        Write-Host("Found Field '" + $field[0].Groups["PropertyName"] + "' that is of type '" + $field[0].Groups["DataType"] + "'")
    }
}

#(?<Word>[\w]{1,}) - words
#field Names = (?<PropertyName>[\w]{1,})[ ]*(?={|=)
#same line - field + datatype
$path = Read-Host "Enter path to C# File"
$fileContent = Get-Content -Path $path | Out-String
$fileContent = Remove-CSharpComments -TextContent $fileContent
Write-Host $fileContent
