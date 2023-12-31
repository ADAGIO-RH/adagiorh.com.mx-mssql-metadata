USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [App].[spIUGeneracionRecibos](
	@IDHistorialEmpleadoPeriodo int
	,@IDPeriodo int
	,@Timbrado bit
	,@IDUsuario int
)
AS
BEGIN
    ------MODIFICACION PROVISIONAL, EL ID DE PERIODO ESTA LLEGANDO EN 0 DESDE EL BACK
    select @IDPeriodo=IDPeriodo
    From nomina.tblHistorialesEmpleadosPeriodos where IDHistorialEmpleadoPeriodo=@IDHistorialEmpleadoPeriodo
	
    insert into Facturacion.tblGeneracionRecibos(IDHistorialEmpleadoPeriodo,IDPeriodo,Timbrado,Generado,FechaHoraCreacion,IDUsuario)
	VALUES(@IDHistorialEmpleadoPeriodo,@IDPeriodo,isnull(@Timbrado,0),0,GETDATE(),@IDUsuario)

END
GO
