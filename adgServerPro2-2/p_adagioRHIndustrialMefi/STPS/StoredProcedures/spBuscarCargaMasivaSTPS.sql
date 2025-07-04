USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarCargaMasivaSTPS]
(
	@IDSucursal int,
	@FechaIni date,
	@FechaFin date,
	@IDUsuario int
)
AS
BEGIN
	
	SELECT 
		 UPPER(M.CURP) as CURP
		,UPPER(COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) as NOMBRE
		,UPPER(M.Paterno) as PRIMERAPELLIDO
		,UPPER(M.Materno) as SEGUNDOAPELLIDO
		,Estados.Codigo as CLAVEESTADO
		,Municipios.Codigo as CLAVEMUNICIPIO
		,ocupaciones.Codigo as CLAVEOCUPACION
		,Estudios.Codigo as CLAVENIVESTUDIOS
		,Probatorios.Codigo as CLAVEDOCPROBATORIO
		,Instituciones.Codigo as CLAVEINSTITUCION
		,C.Codigo AS CLAVECURSO
		,CC.Nombre as NOMBRECURSO
		,Tematica.Codigo as CLAVEAREATEMATICA
		,PCC.Duracion as DURACION
		,FORMAT(PCC.FechaIni,'dd/MM/yyyy') as FECINICIO
		,FORMAT(PCC.FechaFin,'dd/MM/yyyy') as FECTERMINO
		,agentes.Codigo as CLAVETIPAGENTE
		,agentes.RFC as RFCAGENTESTPS
		,modalidades.Codigo as CLAVEMODALIDAD
		,capacitaciones.Codigo as CLAVECAPACITACION
		,S.ClaveEstablecimiento as CLAVEESTABLECIMIENTO
	FROM RH.tblEmpleadosMaster M
		Inner join RH.tblCatSucursales S
			on S.IDSucursal = M.IDSucursal
		Left Join STPS.tblCatEstados Estados
			on Estados.IDEstado = S.IDEstadoSTPS
		left join STPS.tblCatMunicipios Municipios
			on Municipios.IDMunicipio = S.IDMunicipioSTPS
		left join RH.tblCatPuestos Puestos
			on Puestos.IDPuesto = M.IDPuesto
		left join STPS.tblCatOcupaciones ocupaciones
			on ocupaciones.IDOcupaciones = puestos.IDOcupacion
		left join STPS.tblCatEstudios Estudios
			on M.IDEscolaridad = Estudios.IDEstudio
		left join STPS.tblCatProbatorios Probatorios
			on m.IDProbatorio = Probatorios.IDProbatorio
		left join STPS.tblCatInstituciones instituciones
			on instituciones.IDInstitucion = M.IDInstitucion
		inner join STPS.tblProgramacionCursosCapacitacionEmpleados CCE
			on CCE.IDEmpleado = M.IDEmpleado
				and CCE.IDEstatusCursoEmpleados = (Select top 1 IDEstatusCursoEmpleados FROM STPS.tblEstatusCursosEmpleados where Descripcion = 'APROBADO')
		inner join STPS.tblProgramacionCursosCapacitacion PCC
			on PCC.IDProgramacionCursoCapacitacion = CCE.IDProgramacionCursoCapacitacion
		Inner join STPS.tblCursosCapacitacion CC
			on CC.IDCursoCapacitacion = PCC.IDCursoCapacitacion
		left join STPS.tblCatTematicas Tematica
			on Tematica.IDTematica = CC.IDAreaTematica
		left join STPS.tblAgentesCapacitacion agentes
			on PCC.IDAgenteCapacitacion = agentes.IDAgenteCapacitacion
		left join STPS.tblCatModalidades modalidades
			on modalidades.IDModalidad = PCC.IDModalidad
		left join STPS.tblCatCapacitaciones capacitaciones
			on capacitaciones.IDCapacitaciones = CC.IDCapacitaciones
		left join STPS.tblCatCursos C
			on CC.IDCurso = C.IDCursos
	WHERE M.IDSucursal = @IDSucursal
	and PCC.FechaIni >= @FechaIni and PCC.FechaFin <= @FechaFin
	ORDER BY PCC.FechaIni ASC, M.Paterno ASC
	

END
GO
