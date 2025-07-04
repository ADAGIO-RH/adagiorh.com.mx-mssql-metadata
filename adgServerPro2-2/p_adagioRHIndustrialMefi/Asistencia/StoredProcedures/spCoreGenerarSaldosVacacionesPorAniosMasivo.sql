USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Asistencia].[spCoreGenerarSaldosVacacionesPorAniosMasivo](
	 @IDUsuario int = 0
    ,@IDCliente int  = 0
    ,@IDTipoPrestacion int = 0
    ,@IDEmpleado int = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	 

    IF EXISTS(Select top 1 1 from app.tblConfiguracionesGenerales CG where IDConfiguracion = 'RefactorizacionVacaciones' and Valor = 1)
    BEGIN
        PRINT 'REFACTOR'
        DECLARE
        @empleados [RH].[dtEmpleados]  ;	
        
        INSERT @empleados(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion)
        SELECT e.IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion
            FROM RH.tblEmpleadosMaster e WITH(NOLOCK)
        WHERE (e.IDCliente = @IDCliente OR @IDCliente = 0) 
            AND (e.IDTipoPrestacion = @IDTipoPrestacion OR @IDTipoPrestacion = 0)
            AND (e.IDEmpleado = @IDEmpleado OR @IDEmpleado = 0)
            AND Vigente = 1

        SELECT @IDEmpleado = MIN(IDEmpleado) FROM @empleados
        
        WHILE @IDEmpleado <= (SELECT MAX(IDEmpleado) FROM @empleados)
        BEGIN

            EXEC Asistencia.spCoreGenerarSaldosVacacionesPorAniosIndividual @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario

            SELECT @IDEmpleado = MIN(IDEmpleado) FROM @empleados WHERE IDEmpleado > @IDEmpleado
        END

    END
END
GO
