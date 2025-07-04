USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*  
    @Side = 1 Left  
  = 2 Right  
*/  
CREATE function [App].[fnAddString](  
     @Length int  
    ,@Valor nvarchar(max)  
    ,@Char char  
    ,@Side int  
) returns nvarchar(max)  
as  
BEGIN  
   
   set @valor = left(@valor,@Length)
      
   set @Valor = case when @Side = 1 then REPLICATE(@Char, @Length - len(@Valor))+@Valor  
    else @Valor + REPLICATE(@Char, @Length - len(@Valor)) end  
    return @Valor  
END
GO
