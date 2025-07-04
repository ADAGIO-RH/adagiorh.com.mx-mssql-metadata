USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Seguridad].[spAsignarEmpleadosAUsuarioPorFiltroMasivo](
	@IDUsuario int = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IDUsuarioAdmin int
		,@empleados [RH].[dtEmpleados]  
	;	

	IF OBJECT_ID('tempdb..#TempUsuarios') IS NOT NULL DROP TABLE #TempUsuarios

	select @IDUsuarioAdmin = Valor from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'
	
    insert @empleados(IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion)
	select e.IDEmpleado,ClaveEmpleado,Paterno,Materno,SegundoNombre,Nombre,NOMBRECOMPLETO,IDTipoNomina,IDDepartamento,IDSucursal,IDPuesto,IDTipoPrestacion,IDCliente,IDTipoContrato,IdEmpresa,IDRegPatronal,IDDivision,IDClasificacionCorporativa,Vigente,IDCentroCosto,IDArea,IDRegion
	from RH.tblEmpleadosMaster e
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on e.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuarioAdmin

	select u.IDUsuario, m.IDEmpleado 
		into #TempUsuarios
	FROM Seguridad.tblUsuarios U with (nolock)
		left join @empleados M
			on U.IDEmpleado = m.IDEmpleado
	where (
			((U.IDEmpleado is not null) and ISNULL(M.Vigente,0) = 1)
			OR ((U.IDEmpleado is null) AND (u.IDEmpleado IS NULL))
		)
		and (U.IDUsuario = @IDUsuario or ISNULL(@IDUsuario,0) = 0)
		and U.Activo = 1
	ORDER BY u.IDUsuario ASC

	select @IDUsuario = MIN(IDUsuario) from #TempUsuarios
	--select * from #TempUsuarios order by IDUsuario asc
	declare @stringUsuario varchar(100)
	WHILE @IDUsuario <= (Select MAX(IDUsuario) from #TempUsuarios)
	BEGIN
		--print '@IDUsuario:' +cast(@IDUsuario as varchar(10))
		--RAISERROR ('Usuario' , 0, 1) WITH NOWAIT
		set @stringUsuario = cast(@IDUsuario as varchar(100))  
		--RAISERROR (@stringUsuario, 0, 1) WITH NOWAIT


		exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuarioAdmin ,@dtEmpleadosMaster=@empleados  

		select @IDUsuario = MIN(IDUsuario) FROM #TempUsuarios where IDUsuario > @IDUsuario
	END
END
GO
