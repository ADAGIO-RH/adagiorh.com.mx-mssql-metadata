USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Descripción,varchar,Descripción>
** Autor			: <Autor,varchar,Nombre>
** Email			: <Email,varchar,@adagio.com.mx>
** FechaCreacion	: <FechaCreacion,Date,Fecha>
** Paremetros		:              

	

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?

***************************************************************************************************/
--[RH].[spBuscarPosiciones]  @IDEmpleado = 390
CREATE proc [Reportes].[spReportePosicionesReclutamiento](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario	int = 0
) as
BEGIN
	SET FMTONLY OFF;  
	
	declare
		@IDTipoCatalogoEstatusPosiciones int = 5
		,@IDIdioma varchar(20)
	;

	IF OBJECT_ID('tempdb..#TempPosiciones') IS NOT NULL DROP TABLE #TempPosiciones

	

	declare @tempPosiciones as table (
		IDPosicion int,
		IDPlaza int,
		CodigoPlaza App.SMName,
        IDPuesto int,
        IDSucursal int,
        NombrePlaza VARCHAR(100),
		IDCliente int,
		Cliente App.XLName,
		Codigo App.SMName,
		IDEmpleado		int,
		ParentId		int,
		ParentCodigo	varchar(25),
		Temporal		bit,
        DisponibleDesde date,
        DisponibleHasta date,
		UUID			Varchar(max)
	)

	declare @tempEstatusPosiciones as table (
		IDEstatusPosicion int,
		IDPosicion int,
		IDEstatus int,
		Estatus varchar(255),
		DisponibleDesde date,
		DisponibleHasta date,
		IDUsuarioReclutador int,
		IDUsuario int,
		FechaReg datetime,
        ConfiguracionStatus nvarchar(max),
		[ROW] int,
        Idempleado int,
        IDplaza int
       
	)

	insert @tempPosiciones
	select 
		p.IDPosicion
		,p.IDPlaza
		,plazas.Codigo as CodigoPlaza
		,plazas.IDPuesto
        ,JSON_VALUE(plazas.Configuraciones, '$[2].Valor') AS 'IDSucursal'
        ,pp.Descripcion as Descripcion
		,p.IDCliente
		,c.NombreComercial as Cliente
		,p.Codigo
		,p.IDEmpleado
		,p.ParentId
		,ISNULL(p2.Codigo, '0') as ParentCodigo
		,isnull(p.Temporal, 0) Temporal
        ,p.DisponibleDesde
        ,p.DisponibleHasta
		,p.UUID
	from [RH].[tblCatPosiciones] p with (nolock)
		join [RH].[tblCatPlazas] plazas with (nolock) on plazas.IDPlaza = p.IDPlaza
		join [RH].[tblCatClientes] c with (nolock) on c.IDCliente = p.IDCliente
        join  RH.tblCatPuestos pp on pp.IDPuesto=plazas.IDPuesto
		left join [RH].[tblCatPosiciones] p2 with(nolock) on p.ParentId = p2.IDPosicion
       
	

		--select * from @tempPosiciones

	insert @tempEstatusPosiciones
	select 
		isnull(estatusPosiciones.IDEstatusPosicion,0) AS IDEstatusPosicion
		,posiciones.IDPosicion
		,isnull(estatusPosiciones.IDEstatus,0) AS IDEstatus
		,isnull(estatus.Catalogo,'Sin estatus') AS Estatus
		,isnull(estatusPosiciones.DisponibleDesde, '1990-01-01') as DisponibleDesde
		,isnull(estatusPosiciones.DisponibleHasta, '1990-01-01') as DisponibleHasta
		,isnull(estatusPosiciones.IDUsuarioReclutador,0) as IDUsuarioReclutador
		,isnull(estatusPosiciones.IDUsuario,0) as IDUsuario
		,isnull(estatusPosiciones.FechaReg,'1990-01-01') FechaReg
        ,isnull(estatus.configuracion,'') as ConfiguracionStatus
		,ROW_NUMBER()over(partition by posiciones.IDPosicion 
							ORDER by posiciones.IDPosicion, estatusPosiciones.FechaReg  desc) as [ROW]
      
        ,estatusPosiciones.IDEmpleado
        ,posiciones.IDPlaza
        
        
	from @tempPosiciones posiciones
		left join RH.tblEstatusPosiciones estatusPosiciones on estatusPosiciones.IDPosicion = posiciones.IDPosicion 
		left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = estatusPosiciones.IDEstatus and estatus.IDTipoCatalogo = @IDTipoCatalogoEstatusPosiciones
        


	select 
         ROW_NUMBER() over(partition by p.idposicion order by p.idempleado desc) as Orden
		,suc.Descripcion as Sucursal
        ,pue.Descripcion as [Puesto Vacante]
        ,estatus.Estatus as [Estatus Posicion]
        ,case when p.Temporal = 1 then 'SI' else 'NO' end as Temporal
        ,p.DisponibleDesde as [Fecha Solicitud]
        ,FORMAT(canp.FechaAplicacion,'dd/MM/yyyy') as [Fecha de Aplicacion Candidato]
        ,case when e.idempleado is not null then FORMAT(cast(estatus.FechaReg as date),'dd/MM/yyyy') end as [Fecha de Seleccion]
        ,FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as [Fecha de Contratacion]
		,e.NOMBRECOMPLETO as Colaborador 
        ,e2.NOMBRECOMPLETO as [Colaborador Anterior]
        --,DATEDIFF(day,canp.FechaAplicacion,estatus.FechaReg) as [Tiempo de Reclutameinto en Dias]
		,DATEDIFF(day,p.DisponibleDesde,e.FechaAntiguedad) as [Tiempo de Reclutameinto en Dias]
        ,isnull((Select [dbo].[udf_StripHTML] ([Nota]) 
                    from Reclutamiento.tblNotasEntrevistaCandidatoPLaza 
                        where IDCandidato = canp.IDCandidato 
                            FOR XML PATH('') ),'Sin Notas') as Notas
    		
	into #TempPosiciones
	from @tempPosiciones p
        left join rh.tblCatSucursales suc on p.IDSucursal = suc.IDSucursal
        left join rh.tblCatPuestos pue on p.IDPuesto = pue.IDPuesto
		left join RH.tblEmpleadosMaster e on e.IDEmpleado = p.IDEmpleado
		left join @tempEstatusPosiciones estatus on estatus.IDPosicion = p.IDPosicion and estatus.[ROW] = 1
        left join (select 
                    IDPosicion,
                    Idempleado,
                    ROW_NUMBER()OVER(Partition by IDPosicion order by IDPosicion,fechareg desc) as RN
                        from @tempEstatusPosiciones where Idempleado is not null) estatusEmpleado on estatusEmpleado.IDPosicion = p.IDPosicion and rn = 2
        left join RH.tblEmpleadosMaster e2 on e2.IDEmpleado = estatusEmpleado.IDEmpleado
        left join Reclutamiento.tblCandidatos cand on cand.IDEmpleado = p.IDEmpleado
        left join Reclutamiento.tblCandidatoPlaza canp on canp.IDCandidato = cand.IDCandidato and estatus.IDplaza = canp.IDPlaza
        
        
      
    


select * from #TempPosiciones

END
GO
