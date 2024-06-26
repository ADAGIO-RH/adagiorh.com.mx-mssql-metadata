USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarMaestroEmpleadosVigentesExcelCLOE] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select 
		top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with (nolock)       
		Inner join App.tblPreferencias p with (nolock)        
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with (nolock)        
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with (nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare --@dtFiltros [Nomina].[dtFiltrosRH]
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)
			,@IDTipoContactoEmail int
	--insert into @dtFiltros(Catalogo,Value)
	--values('Departamentos',@Departamentos)
	--	,('Sucursales',@Sucursales)
	--	,('Puestos',@Puestos)
	--	,('RazonesSociales',@RazonesSociales)
	--	,('RegPatronales',@RegPatronales)
	--	,('Divisiones',@Divisiones)
	--	,('Prestaciones',@Prestaciones)
	--	,('Clientes',@Cliente)

	
	select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'

	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))

	set @Titulo = UPPER( 'REPORTE MAESTRO DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	
	select @IDTipoContactoEmail = CASE WHEN ISNULL(IDTipoContacto,'') = '' THEN '0' ELSE  IDTipoContacto END
		from [RH].[tblCatTipoContactoEmpleado] where Descripcion = 'EMAIL'



	
	
	--select @IDTipoVigente
	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)

		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
			 m.ClaveEmpleado as CLAVE_RHFLEX	
			,m.IDRegPatronal as REG_PATRONAL	
			,m.RegPatronal   as REG_NOMBRE
			,m.Paterno as PATERNO	
			,m.Materno as MATERNO
			,concat(m.Nombre,' ',m.SegundoNombre) as NOMBRE_SEGUNDO_NOMBRE	
			,m.NOMBRECOMPLETO as NOMBRE_COMPLETO	
			,m.TipoNomina as TIPO_NOMINA	
			,m.IMSS as NSS	                             
			,m.Sexo as SEXO	
			,m.RFC as RFC
			,m.CURP as CURP	
			,m.TipoNomina as TIPO_NOMINA                   --DE NUEVO????
			,m.CentroCosto as CENTRO_DE_COSTO
			,m.Departamento as DEPARTAMENO
			,m.Sucursal as SUCURSAL	
			,m.IDSucursal as CLAVE_SUC	                  
			,m.Puesto   --PUESTO	
			,tp.Descripcion as TipoPrestacion --TIPO PAGO	              
			,Bancos.Descripcion as Banco --BANCO	
			,PE.Interbancaria as ClabeInterbancaria--CUENTA BANCARIA	
			,m.SalarioDiario as SALARIO_DIARIO --SALARIO DIARIO	
		    ,m.SalarioIntegrado AS SALARIO_INTEGRADO --SALARIO INTEGRADO	
			,m.Escolaridad  --ESCOLARIDAD	
			,m.FechaIngreso --FECHA INGRESO	
			,m.FechaAntiguedad--FECHA ANTIGUEDAD	
			,FechaUltimaBaja = (select top 1 m.Fecha 
								from IMSS.tblMovAfiliatorios m with (nolock)  
									join IMSS.tblCatTipoMovimientos ctm with (nolock)  
										on m.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
								order by m.Fecha desc ) --UTLIMA BAJA	
			,causaUltimaBaja = (select top 1 crm.Descripcion
								from IMSS.tblMovAfiliatorios m with (nolock)  
									join IMSS.tblCatTipoMovimientos ctm with (nolock)  
										on m.IDTipoMovimiento = ctm.IDTipoMovimiento 
									join [IMSS].[tblCatRazonesMovAfiliatorios] crm
										on m.IDRazonMovimiento = crm.IDRazonMovimiento
								where IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
								order by m.Fecha desc ) --CAUSA BAJA	
			,direccion.calle as CALLE	
			,direccion.Exterior as NUM_EXT
			,direccion.CodigoPostal AS	CodigoPostal	
			,direccion.Colonia as COLONIA	
			,direccion.Municipio as MUNICIPIO	
			,direccion.Estado as ESTADO	
			,m.LocalidadNacimiento as LUGAR_DE_NACIMIENTO	
			,Email = (select  top 1 tce.Value from [RH].[tblContactoEmpleado] tce
					where IDEmpleado = m.IDEmpleado and IDTipoContactoEmpleado = @IDTipoContactoEmail
					order by tce.IDContactoEmpleado desc )
			,InfonavitTipoDescuento.Descripcion as TipoDescuentoInfonavit --TIPO DESCUENTO 
			,Infonavit.NumeroCredito as NumeroCreditoInfonavit --INF	VALOR CREDITO	
			,Infonavit.ValorDescuento as VALOR_BIMESTRE	
			,m.FechaNacimiento as FECHA_NAC	
			,DATEDIFF(DAY, m.FechaNacimiento, GetDate()) / 365.25 as Edad --EDAD	
			,m.EstadoCivil

			,JefeInmediato = (select top 1  tem.NOMBRECOMPLETO from [RH].[tblJefesEmpleados] tje
								join RH.tblEmpleadosMaster tem on tje.IDJefe = tem.IDEmpleado
								where tje.IDJefe = m.IDEmpleado
								order by tje.IDJefeEmpleado desc) 

			,PapaOMama = (SELECT 
						 case when count(*) > 0 then 1 else 0 end
						FROM 
						 [RH].[TblFamiliaresBenificiariosEmpleados]  tbb
						 where (IDParentesco = 4 or  IDParentesco = 5)
						 and tbb.IDEmpleado = IDEmpleado ) --ES PAPA O MAMÁ	
			,NumHijos = 
					(select COUNT(*) from [RH].[TblFamiliaresBenificiariosEmpleados] tbb
					where IDParentesco = 4 and tbb.IDEmpleado = IDEmpleado ) --NUMERO DE HIJOS	

			,NumHijas = 
					(select COUNT(*) from [RH].[TblFamiliaresBenificiariosEmpleados] tbb
					where IDParentesco = 5 and tbb.IDEmpleado = IDEmpleado ) --NUMERO DE HIJAS


		 from @dtEmpleados m
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) 
				on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) 
				on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) 
				on direccion.IDEmpleado = M.IDEmpleado
					and direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) 
				on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) 
				on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) 
				on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) 
				on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) 
				on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) 
				on direccion.IDRuta = rutas.IDRuta
			left join RH.tblInfonavitEmpleado Infonavit with (nolock) 
				on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) 
				on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) 
				on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
					and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) 
				on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) 
				on TC.IDTipoContrato = TTE.IDTipoContrato
		--where IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
		--	or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0'

	END
GO
