USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Nomina].fnAjustaNeto       
(      
 @Percepciones decimal(18,4),      
 @Deducciones decimal(18,4),      
 @Ajusta int      
)      
RETURNS decimal(18,4)       
AS      
BEGIN      
      
DECLARE @total decimal(18,2),      
 @Round decimal(18,2),      
 @final decimal(18,2)      
      
set @total = @Percepciones  - @Deducciones    
      
set @Round = CASE WHEN @Ajusta = 0 THEN round(@total ,0)
				WHEN @Ajusta = 1 THEN round(@total ,1)
				ELSE round(@total ,2)
				END
set @final = (@total - @Round)  
      
return @final;      
      
END
GO
