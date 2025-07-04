USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Auditoria].[spIAuditoriaVacaciones]
(
	@IDUsuario int,
	@Tabla Varchar(100),
	@Procedimiento Varchar(255),
	@Accion Varchar(255),
	@NewData Varchar(MAX),
	@OldData Varchar(MAX),
	@Mensaje Varchar(MAX) = null,
	@InformacionExtra varchar(max) = null,
    @IDCliente int = 0,
    @IDTipoPrestacion int = 0
)
AS
BEGIN
	DECLARE @empleados [RH].[dtEmpleados];


    INSERT @empleados(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion)
    SELECT e.IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion
        FROM RH.tblEmpleadosMaster e WITH(NOLOCK)
    WHERE (e.IDCliente = @IDCliente OR @IDCliente = 0) 
        AND (e.IDTipoPrestacion = @IDTipoPrestacion OR @IDTipoPrestacion = 0)
        AND Vigente = 1

	insert into [Auditoria].[tblAuditoria](IDUsuario,Fecha,Tabla,Procedimiento,Accion,NewData,OldData, IDEmpleado, Mensaje, InformacionExtra)
	Select @IDUsuario,GETDATE(),@Tabla,@Procedimiento,@Accion,@NewData,@OldData, IDEmpleado, @Mensaje,@InformacionExtra from @empleados

END
GO
