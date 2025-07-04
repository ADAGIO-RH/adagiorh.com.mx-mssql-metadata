USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Asistencia].[spIBitacoraChecadas](
	@IDEmpleado	int = null,
	@Fecha		datetime = null,
	@IDLector	int = null,
	@Mensaje	varchar(MAX) = null,
	@Latitud	float = null,
	@Longitud	float = null
)
AS
BEGIN
	INSERT INTO Asistencia.tblBitacoraChecadas(IDEmpleado,Fecha,IDLector,Mensaje,Latitud,Longitud)
	select @IDEmpleado,isnull(@Fecha,getdate()),@IDLector,@Mensaje,@Latitud,@Longitud
END
GO
