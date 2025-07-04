USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/****************************************************************************************************   
** Descripción  : Function para obtener los Dias de Aguinaldo Proporcionales  
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 16-08-2018  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
  
 
CREATE FUNCTION [Asistencia].[fnBuscarDiasAguinaldoProporcionales]  
(  
 @IDEmpleado int,  
 @IDTipoPrestacion int,  
 @FechaIni Date,  
 @FechaFin Date   
)  
returns Decimal(18,2)  
AS  
BEGIN  
  DECLARE   
    @Antiguedad decimal(18,2),  
    @DiasAguinaldoProp decimal(18,2) = 0,
	@FechaInicialAnio Date,
	@Dias decimal(18,2),
	@InicioDeAno Date,
	@FinDeAno Date 

	set @InicioDeAno = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) 
	set @FinDeAno = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)

	set @FechaInicialAnio = cast(YEAR(@FechaFin) as varchar(4)) + '-01-01'
    
	set @Dias = DATEDIFF(day,@FechaInicialAnio,@FechaFin) +1

  Select @Antiguedad = Cast(DATEDIFF(DAY,@FechaIni,@FechaFin) as decimal) / ( DATEDIFF( day , @InicioDeAno , @FinDeAno ) + 1 )  
  
 Select top 1 @DiasAguinaldoProp =  ( (CAST(DiasAguinaldo as decimal) / ( DATEDIFF( day , @InicioDeAno , @FinDeAno ) + 1 )   ) * @Dias)  
 from [RH].[tblCatTiposPrestacionesDetalle]  
 where IDTipoPrestacion = @IDTipoPrestacion  
  and Antiguedad >= case when @Antiguedad < 1 then 1 Else @Antiguedad END  
 ORDER BY Antiguedad ASC  
  
 return @DiasAguinaldoProp;  
END
GO
