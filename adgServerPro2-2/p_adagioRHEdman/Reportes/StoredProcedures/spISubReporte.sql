USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Reportes].[spISubReporte]
	-- Add the parameters for the stored procedure here
	
    @IDReporteBasico int  null,    
    @Nombre VARCHAR(max)

AS
BEGIN

    
	INSERT INTO Reportes.tblCatReportesBasicosSubReportes (IDReporteBasico,Nombre)
    values(@IDReporteBasico,@Nombre);
    
    SELECT @@IDENTITY  [IDSubreporte];
    
END
GO
