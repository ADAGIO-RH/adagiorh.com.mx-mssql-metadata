USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE App.spIUGeneracionRecibos(
	@IDHistorialEmpleadoPeriodo int
	,@IDPeriodo int
	,@Timbrado bit
	,@IDUsuario int
)
AS
BEGIN

	insert into Facturacion.tblGeneracionRecibos(IDHistorialEmpleadoPeriodo,IDPeriodo,Timbrado,Generado,FechaHoraCreacion,IDUsuario)
	VALUES(@IDHistorialEmpleadoPeriodo,@IDPeriodo,isnull(@Timbrado,0),0,GETDATE(),@IDUsuario)

END
GO
