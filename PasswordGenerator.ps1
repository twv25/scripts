function Get-RandomPassword{            

[CmdletBinding()]            
param (                    
   [parameter()]            
   [int]$CharRepeatMax = 3,            
   [parameter()]            
   [int]$Generate = 1            
)            

$length = Get-Random -minimum 9 -maximum 36
   
   For($i=0; $i -lt $Generate; $i++)             
   {            
      ## * Randomly generate up to $CharRepeatMax sets of !-', 0-9, ?-Z, a-z            
      ## * Randomly generate a password of $Length            
      ## * Ouput as many password as $Generate            
      
      $GeneratedPass = $(             
        
         $([char[]]@(33..39) * (Get-Random -Min 1 -Max ($CharRepeatMax + 1)) |             
            Get-Random -Count ([int]::MaxValue)) +
         
         $([char[]]@(48..57) * (Get-Random -Min 1 -Max ($CharRepeatMax + 1)) |             
            Get-Random -Count ([int]::MaxValue)) +             

         $([char[]]@(63..90) * (Get-Random -Min 1 -Max ($CharRepeatMax + 1)) |             
            Get-Random -Count ([int]::MaxValue)) +             

         $([char[]]@(97..122) * (Get-Random -Min 1 -Max ($CharRepeatMax + 1)) |             
            Get-Random -Count([int]::MaxValue)         

      ) | Get-Random -Count $Length) -join ""             

      New-Object PSObject -Property @{ Password = $GeneratedPass }            
   }            
}