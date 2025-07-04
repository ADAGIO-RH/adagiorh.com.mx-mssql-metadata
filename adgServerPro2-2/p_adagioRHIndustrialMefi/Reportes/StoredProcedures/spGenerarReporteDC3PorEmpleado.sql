USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spGenerarReporteDC3PorEmpleado]
(
	@IDProgramacionCursoCapacitacion int,
	@IDsEmpleados Varchar(max) = '',
	@IDUsuario int
)
AS
BEGIN
	declare @SPCustomReporteDC3PorEmpleado Varchar(max);

	SELECT top 1 @SPCustomReporteDC3PorEmpleado = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'SPCustomReporteDC3PorEmpleado'

	IF(ISNULL(@SPCustomReporteDC3PorEmpleado,'') <> '')
	BEGIN
		exec sp_executesql 
			 N'exec @miSP @IDProgramacionCursoCapacitacion ,@IDsEmpleados  ,@IDUsuario'                   
			,N' @IDProgramacionCursoCapacitacion int        
			,@IDsEmpleados Varchar(max)
			,@IDUsuario int      
			,@miSP varchar(MAX)',                          
			@IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion      
			,@IDsEmpleados = @IDsEmpleados  
			,@IDUsuario = @IDUsuario       
			,@miSP = @SPCustomReporteDC3PorEmpleado ; 
		RETURN;
	END

	declare
		 @MostrarNombreInstructorParaFirma bit = 0
		,@NombreRepresentanteLegal		   varchar(255) = ''
		,@NombreRepresentanteTrabajadores  varchar(255) = ''
		,@PathLogoEmpresas varchar(max) = ''
	;

	set @MostrarNombreInstructorParaFirma	= isnull((select top 1 [Valor] from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'MostrarNombreInstructorParaFirma'),0)
	set @NombreRepresentanteLegal			= isnull((select top 1 [Valor] from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'NombreRepresentanteLegal'		  ),'')
	set @NombreRepresentanteTrabajadores	= isnull((select top 1 [Valor] from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'NombreRepresentanteTrabajadores' ),'')
	set @PathLogoEmpresas					= isnull((select top 1 [Valor] from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'PathLogoEmpresas' ),'')

	Select 
		M.ClaveEmpleado
		,m.NOMBRECOMPLETO as NombreCompleto
		,m.CURP
		,o.Codigo as OcupacionCodigo
		,o.Descripcion as OcupacionDescripcion
		,m.Puesto
		,m.Empresa
		,E.RFC
		,coalesce(CC.Codigo,'') +' - '+coalesce(CC.Nombre,'') as CursoCapacitacion
		,PCC.Duracion
		,PCC.FechaIni
		,PCC.FechaFin
		,upper(coalesce(T.Codigo,'')+' - '+ coalesce(t.Descripcion,'')) as AreaTematica
		,coalesce(AC.Nombre,'') +' '+coalesce(AC.Apellidos,'') as NombreCompletoAgenteCapacitacion
		,NombreCompletoAgenteCapacitacionFirma = case when @MostrarNombreInstructorParaFirma = 1 then coalesce(AC.Nombre,'') +' '+ coalesce(AC.Apellidos,'') else '' end 
		,@NombreRepresentanteLegal		  as NombreRepresentanteLegal		
		,@NombreRepresentanteTrabajadores as NombreRepresentanteTrabajadores
		,coalesce(@PathLogoEmpresas,'')+cast(e.IdEmpresa as Varchar(100))+'.jpg' as LogoEmpresa
	from STPS.tblProgramacionCursosCapacitacionEmpleados CCE with (nolock)
		inner join STPS.tblProgramacionCursosCapacitacion pcc with (nolock) on CCE.IDProgramacionCursoCapacitacion = pcc.IDProgramacionCursoCapacitacion
		inner join STPS.tblCursosCapacitacion CC with (nolock) on CC.IDCursoCapacitacion = PCC.IDCursoCapacitacion
		left join STPS.tblCatTematicas t with (nolock) on CC.IDAreaTematica = t.IDTematica
		left join STPS.tblAgentesCapacitacion AC with (nolock) on AC.IDAgenteCapacitacion = PCC.IDAgenteCapacitacion
		inner join STPS.tblEstatusCursosEmpleados ECE with (nolock) on ECE.IDEstatusCursoEmpleados = CCE.IDEstatusCursoEmpleados
		inner join RH.tblEmpleadosMaster M with (nolock) on CCE.IDEmpleado = M.IDEmpleado
		left join RH.tblCatPuestos p with (nolock) on p.IDPuesto = m.IDPuesto
		left join STPS.tblCatOcupaciones O with (nolock) on p.IDOcupacion = o.IDOcupaciones
		left join RH.tblEmpresa E with (nolock) on E.IdEmpresa = M.IDEmpresa
	WHERE CCE.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion	
		and CCE.IDEmpleado in (Select Item from app.Split(@IDsEmpleados,','))
		and CCE.IDEstatusCursoEmpleados = (Select IDEstatusCursoEmpleados from STPS.tblEstatusCursosEmpleados with (nolock) where Descripcion = 'APROBADO')
				
END
GO
