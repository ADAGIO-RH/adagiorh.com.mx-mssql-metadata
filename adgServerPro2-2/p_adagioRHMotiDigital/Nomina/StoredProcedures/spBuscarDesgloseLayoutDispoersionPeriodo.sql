USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar desglose del periodo para las dispersiones
** Autor			: JOSE RAFAEL ROMÁN GIL
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-06-20			Victor Martinez		Corrige error en JSON_VALUE del campo TipoPrestacion
2024-09-03			Aneudy Abreu		Agrega campo Region
2025-04-07			Aneudy Abreu		Quita el campo @IDTipoNomina de la consulta de empleados
***************************************************************************************************/
CREATE PROCEDURE  [Nomina].[spBuscarDesgloseLayoutDispoersionPeriodo](        
	@IDPeriodo int  
	,@dtFiltros [Nomina].[dtFiltrosRH]  readonly       
	,@IDUsuario int      
)        
AS        
BEGIN        
	declare         
		@empleados [RH].[dtEmpleados]          
		,@ListaEmpleados Nvarchar(max) 
		,@periodo [Nomina].[dtPeriodos]  
		,@fechaIniPeriodo  date                  
		,@fechaFinPeriodo  date
		,@IDTipoNomina int          
        ,@IDIdioma varchar(max)     
	;

    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos with(nolock)                 
	where IDPeriodo = @IDPeriodo                  
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago                  
	from @periodo                  
	              
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
	
	--  @IDTipoNomina=@IDTipoNomina, 
	insert into @empleados                  
	exec [RH].[spBuscarEmpleadosMaster] @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros , @IDUsuario= @IDUsuario   

	select         
		p.IDPeriodo,        
		p.ClavePeriodo,        
		p.Descripcion as Periodo,        
		p.FechaInicioPago,        
		p.FechaFinPago,                
		e.IDEmpleado,        
		e.ClaveEmpleado,        
		e.NOMBRECOMPLETO,        
		e.RFC,        
		ISNULL(pe.Cuenta,'') as Cuenta,  
        ISNULL(pe.Interbancaria,'') as Interbancaria,
        ISNULL(pe.Tarjeta,'') as Tarjeta,
        Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(e.IDEmpleado,0) as UsuarioEmpleadoFotoAvatar,
		isnull(lp.IDLayoutPago,0) as IDLayoutPago,        
		isnull(lp.Descripcion,'NO ASIGNADO') as LayoutPago,        
		isnull(Banco.IDBanco,0) IDBanco,        
		ISNULL(Banco.Codigo,'000') as CodigoBanco,        
		ISNULL(Banco.Descripcion,'NO ASIGNADO') Banco,        
		ISNULL(dpPagado.ImporteGravado,0.00) as ImporteGravado,        
		ISNULL(dpPagado.ImporteExcento,0.00) as ImporteExcento,        
		ISNULL(dpPagado.ImporteTotal1,0.00) as ImporteTotal1,        
		ISNULL(dpPagado.ImporteTotal2,0.00) as ImporteTotal2,        
		ISNULL(c.IDConcepto,0) as IDConcepto,        
		ISNULL(c.Codigo,'000') as CodigoConcepto,        
		ISNULL(c.Descripcion,'NO ASIGNADO') as Concepto, 
		ISNULL(e.IDDepartamento,0) as IDDepartamento,        
		ISNULL(e.Departamento,'NO ASIGNADO') as Departamento,
		ISNULL(e.IDSucursal,0) as IDSucursal,        
		ISNULL(e.Sucursal,'NO ASIGNADO') as Sucursal,		
		ISNULL(e.IDPuesto,0) as IDPuesto,        
		ISNULL(e.Puesto,'NO ASIGNADO') as Puesto,		
		ISNULL(e.IDDivision,0) as IDDivision,        
		ISNULL(e.Division,'NO ASIGNADO') as Division,	
		ISNULL(e.IDClasificacionCorporativa,0) as IDClasificacionCorporativa,        
		ISNULL(e.ClasificacionCorporativa,'NO ASIGNADO') as ClasificacionCorporativa,	
		ISNULL(e.IDCentroCosto,0) as IDCentroCosto,        
		ISNULL(e.CentroCosto,'NO ASIGNADO') as CentroCosto,
		ISNULL(e.IDTipoNomina,0) as IDTipoNomina,        
		ISNULL(e.TipoNomina,'NO ASIGNADO') as TipoNomina,	   
		ISNULL(tp.IDTipoPrestacion,0) as IDTipoPrestacion,       
        --JSON_VALUE(ISNULL(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'NO ASIGNADO')as TipoPrestacion,
		ISNULL(JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'NO ASIGNADO')as TipoPrestacion, 
		--ISNULL(tp.Descripcion,'NO ASIGNADO') as TipoPrestacion,
		ISNULL(e.Empresa,'NO ASIGNADO') as RazonSocial,
		ISNULL(e.RegPatronal,'NO ASIGNADO') as RegPatronal,
		ISNULL(e.Region,'NO ASIGNADO') as Region,
		CASE WHEN ISNULL(LDE.IDControlLayoutDispersionEmpleado,0) = 0 THEN 'NO' ELSE 'SI'	END as Pagado        
	FROM  @empleados e        
		INNER JOIN Nomina.tblCatPeriodos p with(nolock) on p.IDPeriodo = @IDPeriodo       
		INNER JOIN Nomina.tblDetallePeriodo dpPagado with(nolock) on dpPagado.IDPeriodo = @IDPeriodo        
			and dpPagado.IDEmpleado = e.IDEmpleado        
	   --and (dpPagado.IDConcepto in (Select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = (Select IDTipoConcepto from Nomina.tblCatTipoConcepto where Descripcion = 'CONCEPTOS DE PAGO' )) 
		    --OR 
		--	and (dpPagado.IDConcepto = pe.IDConcepto)
			--) 
			and (dpPagado.ImporteTotal1 > 0 OR dpPagado.ImporteTotal2 >0)   
		inner JOIN  Nomina.tblLayoutPago lp with(nolock) on (lp.IDConcepto = dpPagado.IDConcepto
				or lp.IDConceptoFiniquito = dpPagado.IDConcepto
			)
		inner JOIN RH.tblPagoEmpleado pe with(nolock) on pe.IDEmpleado = e.IDEmpleado 
			and pe.IDLayoutPago = lp.IDLayoutPago
		left JOIN Nomina.tblCatConceptos c with(nolock) on dpPagado.IDConcepto = c.IDConcepto    
	--and (dpPagado.ImporteTotal1 > 0 OR dpPagado.ImporteTotal2 >0)   
		left join Nomina.tblControlLayoutDispersionEmpleado LDE with(nolock) on LDE.IDEmpleado = E.IDEmpleado
			and LDE.IDLayoutPago = lp.IDLayoutPago
			and LDE.IDPeriodo = @IDPeriodo        
		LEFT JOIN Sat.tblCatBancos Banco with(nolock) on Banco.IDBanco = pe.IDBanco        
		left join RH.tblCatTiposPrestaciones tp with(nolock) on tp.IDTipoPrestacion = e.IDTipoPrestacion    
	--where  (dpPagado.IDConcepto in (Select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = (Select IDTipoConcepto from Nomina.tblCatTipoConcepto where Descripcion = 'CONCEPTOS DE PAGO' ))) 
		 order by e.ClaveEmpleado
END
GO
