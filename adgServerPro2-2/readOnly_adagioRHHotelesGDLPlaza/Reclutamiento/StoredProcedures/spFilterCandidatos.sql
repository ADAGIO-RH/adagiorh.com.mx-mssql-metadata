USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados por Nombre y/o clave Empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-24
** Paremetros		:              
	@tipo = 1		: Vigentes
			0		: No Vigentes
			Null	: Ambos

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2020-10-13			Joseph Roman	Se agrega campo de Descripcion de TiposPrestacion 
									Para que cargue la variable en el trabajador en la busqueda rapida.
***************************************************************************************************/
CREATE proc [Reclutamiento].[spFilterCandidatos](  
	@IDUsuario	int = 0  
	,@filter	varchar(1000)   
)as   
--declare   
    --@FechaIni date = '1900-01-01',  
    --@Fechafin date = '9999-12-31',  
    --@empleados [RH].[dtEmpleados]  
    --,@dtFiltros [Nomina].[dtFiltrosRH];  
  
    --insert into @dtFiltros(Catalogo,Value)  
    --select 'NombreClaveFilter',@filter  
  
  --  insert into @empleados  
    --exec [RH].[spBuscarEmpleados]   
    --@IDUsuario=@IDUsuario  
    --,@dtFiltros = @dtFiltros  
	DECLARE @IDDocumentoTrabajoPasaporte INT;

	SELECT 
		@IDDocumentoTrabajoPasaporte = IDDocumentoTrabajo
	FROM 
		[Reclutamiento].[tblCatDocumentosTrabajo]
	WHERE 
		[Descripcion] = 'PASAPORTE'
  
	declare @IDEmpleado int

	select @IDEmpleado = isnull(IDEmpleado,0) from Seguridad.tblUsuarios where IDUsuario = @IDUsuario

	SELECT 
		 [Candidato].[IDCandidato]  as [IDCandidato]
		,concat ([Nombre], ' ', [SegundoNombre],' ',[Paterno], ' ' ,[Materno]) as [Nombre]
		,ISNULL('-','') as [SegundoNombre]
		,[SegundoNombre]
		,[Paterno]
		,[Materno]
		,[Sexo]
		,[FechaNacimiento]
		,[IDPaisNacimiento]
		,[IDEstadoNacimiento]
		,[IDMunicipioNacimiento]
		,[IDLocalidadNacimiento]
		,[RFC]
		,[CURP]
		,[NSS]
		,[IDAfore]
		,[IDEstadoCivil]
		,[Estatura]
		,[Peso]
		,[TipoSangre]
		,[Extranjero]
		,ISNULL(CandidatosProceso.[VacanteDeseada],'') as [VacanteDeseada]
		,ISNULL(CandidatosProceso.[SueldoDeseado],'') as [SueldoDeseado]
		,ISNULL(CandidatosProceso.IDPuestoPreasignado,0) as [IDPuestoPreasignado]
		,ISNULL(CandidatosProceso.[SueldoPreasignado],'') as [SueldoPreasignado]
		,ISNULL(CandidatosProceso.IDEstatusProceso,0) as [IDEstatusProceso]
		,ROW_NUMBER()over(ORDER BY Candidato.[IDCandidato])as ROWNUMBER

	FROM [Reclutamiento].[tblCandidatos] Candidato
	left JOIN [Reclutamiento].[tblCandidatosProceso] CandidatosProceso ON CandidatO.IDCandidato = CandidatosProceso.IDCandidato
	--inner join Reclutamiento.tblCatEstatusProceso proceso on CandidatosProceso.IDEstatusProceso = proceso.IDEstatusProceso

	
	where 
		[Nombre] like '%'+@filter+'%'  or
		[SegundoNombre] like '%'+@filter+'%'  or
		[Paterno] like '%'+@filter+'%'  or
		[Materno] like '%'+@filter+'%'  or
		[RFC] like '%'+@filter+'%'  or
		[CURP] like '%'+@filter+'%'  

		
	order by Candidato.IDCandidato asc

	/*select  e.*
		   ,TP.Descripcion as TiposPrestacion	  
	from [RH].[tblEmpleadosMaster] e with (nolock)
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) 
			on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join RH.tblCatTiposPrestaciones TP
			on e.IDTipoPrestacion = TP.IDTipoPrestacion
	where [ClaveNombreCompleto] like '%'+@filter+'%'  
		and (e.Vigente = case when @tipo is not null then @tipo else e.Vigente end)
		and (e.IDEmpleado <> case when @intranet = 1 then @IDEmpleado else 0  end)
	order by ClaveEmpleado asc*/
GO
