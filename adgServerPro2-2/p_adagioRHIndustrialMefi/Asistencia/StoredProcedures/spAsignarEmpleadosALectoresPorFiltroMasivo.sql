USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [Asistencia].[spAsignarEmpleadosALectoresPorFiltroMasivo](
	@IDUsuario int = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IDUsuarioAdmin int
		,@empleados [RH].[dtEmpleados] 
		,@IDLector int
	;	

	IF OBJECT_ID('tempdb..#TempLectores') IS NOT NULL DROP TABLE #TempLectores

	select @IDUsuarioAdmin = Valor from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'
	
    insert @empleados(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion)
	select e.IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion
	from RH.tblEmpleadosMaster e
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on e.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuarioAdmin

	select L.IDLector
		into #TempLectores
	FROM Asistencia.tblLectores L with (nolock)
		


	select @IDLector = MIN(IDLector) from #TempLectores
	declare @stringLector varchar(100)
	WHILE @IDLector <= (Select MAX(IDLector) from #TempLectores)
	BEGIN
		print '@IDLector:' +cast(@IDLector as varchar(10))
		--RAISERROR ('Lector' , 0, 1) WITH NOWAIT
		set @stringLector = cast(@IDLector as varchar(100))  
		--RAISERROR (@stringLector, 0, 1) WITH NOWAIT

		exec [Asistencia].[spAsignarEmpleadosALectoresPorFiltro] @IDLector = @IDLector, @IDUsuarioLogin = @IDUsuarioAdmin ,@dtEmpleadosMaster=@empleados  

		select @IDLector = MIN(IDLector) FROM #TempLectores where IDLector > @IDLector
	END
END
GO
