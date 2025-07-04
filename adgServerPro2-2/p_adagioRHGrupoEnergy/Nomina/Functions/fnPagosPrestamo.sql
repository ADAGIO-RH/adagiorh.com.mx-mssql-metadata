USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Nomina].[fnPagosPrestamo]    
(    
 @IDPrestamo int    
)    
RETURNS @Lista TABLE    
(    
 IDPrestamo int,  
 Codigo varchar(20),  
 IDPrestamoDetalle int,         
 IDConcepto int,    
 Concepto Varchar(50),    
 IDPeriodo int,    
 ClavePeriodo varchar(25),    
 MontoCuota Decimal(18,4),    
 FechaPago date,
 Receptor Varchar(255),
 IDUsuario int,
 Usuario Varchar(255)    
)    
AS    
BEGIN    
    
 insert into @Lista    
 Select *    
 from(    
	-- Préstamo nuevo
	--select  
	--	p.IDPrestamo, 
	--	p.Codigo,   
	--	0 IDPrestamoDetalle,    
	--	tp.IDConcepto,    
	--	c.Descripcion as Concepto,    
	--	0 as IDPeriodo,    
	--	'' ClavePeriodo,    
	--	0 MontoPrestamo,    
	--	'1990-01-01' FechaPago,
	--	'NINGUNO' Receptor,
	--	0 IDUsuario,
	--	'' as Usuario    
	--from Nomina.tblCatTiposPrestamo tp    
	--	inner join	Nomina.tblPrestamos p    
	--	on tp.IDTipoPrestamo = p.IDTipoPrestamo    
	--	inner join Nomina.tblCatEstatusPrestamo ep    
	--	on ep.IDEstatusPrestamo = p.IDEstatusPrestamo    
	--	left join Nomina.tblCatConceptos c    
	--	on tp.IDConcepto = c.IDConcepto    
	--Where p.IDPrestamo = @IDPrestamo and p.IDEstatusPrestamo =  1
	--Union   
	-- Abonos manuales al préstamo 
	select  
		p.IDPrestamo,    
		p.Codigo,
		pd.IDPrestamoDetalle,    
		tp.IDConcepto,    
		c.Descripcion as Concepto,    
		isnull(periodos.IDPeriodo,0) as IDPeriodo,    
		isnull(periodos.ClavePeriodo,'ABONO SIN PERIODO') AS ClavePeriodo,    
		pd.MontoCuota,    
		pd.FechaPago,
		pd.Receptor,
		pd.IDUsuario,
		u.Cuenta as Usuario    
	from Nomina.tblCatTiposPrestamo tp with(nolock)   
		inner join Nomina.tblPrestamos p  with(nolock)      
		on tp.IDTipoPrestamo = p.IDTipoPrestamo    
		inner join Nomina.tblCatEstatusPrestamo ep  with(nolock)     
		on ep.IDEstatusPrestamo = p.IDEstatusPrestamo    
		inner join Nomina.tblPrestamosDetalles pd with(nolock)      
		on p.IDPrestamo = pd.IDPrestamo    
		left join Nomina.tblCatConceptos c  with(nolock)     
		on tp.IDConcepto = c.IDConcepto    
		left join Nomina.tblCatPeriodos periodos  with(nolock)     
		on periodos.IDPeriodo = pd.IDPeriodo 
		left join Seguridad.tblUsuarios u with(nolock)   
		on u.IDUsuario = pd.IDUsuario	   
	Where p.IDPrestamo = @IDPrestamo    
  Union    
	-- Descuentos en nómina del préstamo
	select   
		p.IDPrestamo, 
		p.Codigo,   
		0 as IDPrestamoDetalle,    
		tp.IDConcepto,    
		c.Descripcion as Concepto,    
		periodos.IDPeriodo,    
		periodos.ClavePeriodo,    
		dp.ImporteTotal1 as MontoCuota,    
		periodos.FechaFinPago as FechaPago,
		'' as Receptor,
		0 as IDUsuario,
		'' as Usuario     
	from Nomina.tblCatTiposPrestamo tp   with(nolock)    
		inner join Nomina.tblPrestamos p with(nolock)      
		on tp.IDTipoPrestamo = p.IDTipoPrestamo    
		inner join Nomina.tblCatEstatusPrestamo ep   with(nolock)    
		on ep.IDEstatusPrestamo = p.IDEstatusPrestamo    
		inner join Nomina.tblDetallePeriodo dp with(nolock)      
		on tp.IDConcepto = dp.IDConcepto    
		inner join Nomina.tblCatConceptos c with(nolock)      
		on tp.IDConcepto = c.IDConcepto    
		inner join Nomina.tblCatPeriodos periodos  with(nolock)     
		on periodos.IDPeriodo = dp.IDPeriodo    
	Where p.IDPrestamo = @IDPrestamo    
		and periodos.Cerrado = 1    
		and dp.IDReferencia = @IDPrestamo    
 ) Results    
    
 ORDER BY FechaPago ASC    
    
return    
END
GO
