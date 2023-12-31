USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Nomina].[spLayoutSANTANDER_B]   
	(    
		@IDPeriodo int,    
		@FechaDispersion date,    
		@IDLayoutPago int,
		@dtFiltros [Nomina].[dtFiltrosRH]  readonly,
		@MarcarPagados bit = 0,     
		@IDUsuario int      
	)    
	AS

	
	BEGIN 
		DECLARE 
			@empleados [RH].[dtEmpleados]      
			,@ListaEmpleados Nvarchar(max)    
			,@periodo [Nomina].[dtPeriodos]  
			,@fechaIniPeriodo  date                  
			,@fechaFinPeriodo  date
			,@IDTipoNomina int 
			,@NombrePeriodo Varchar(20)
			,@ClavePeriodo Varchar(16)
			,@CountEmpleados int 
			,@Contador int = 0

			-- PARAMETROS
			,@TipoPago Varchar(36) --Tipo Pago
			,@NoCuenta Varchar(20) --Cuenta Cargo
			,@Correo Varchar(40) --Correo


			Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
			select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
			from Nomina.TblCatPeriodos                  
			where IDPeriodo = @IDPeriodo                  
                  
			select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago , @NombrePeriodo = Descripcion , @ClavePeriodo = ClavePeriodo                
			from @periodo   

			/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
			insert into @empleados                  
			exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario 

			-- CARGAR PARAMETROS EN VARIABLES

			select @TipoPago = lpp.Valor  
				from Nomina.tblLayoutPago lp  
					inner join Nomina.tblLayoutPagoParametros lpp  
						on lp.IDLayoutPago = lpp.IDLayoutPago  
					inner join Nomina.tblCatTiposLayoutParametros ctlp  
						on ctlp.IDTipoLayout = lp.IDTipoLayout  
							and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
				where lp.IDLayoutPago = @IDLayoutPago  
					and ctlp.Parametro = 'Tipo Pago' 

			select @NoCuenta = lpp.Valor  
				from Nomina.tblLayoutPago lp  
					inner join Nomina.tblLayoutPagoParametros lpp  
						on lp.IDLayoutPago = lpp.IDLayoutPago  
					inner join Nomina.tblCatTiposLayoutParametros ctlp  
						on ctlp.IDTipoLayout = lp.IDTipoLayout  
							and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
				where lp.IDLayoutPago = @IDLayoutPago  
					and ctlp.Parametro = 'No. Cuenta' 
 
            select @Correo = lpp.Valor  
				from Nomina.tblLayoutPago lp  
					inner join Nomina.tblLayoutPagoParametros lpp  
						on lp.IDLayoutPago = lpp.IDLayoutPago  
					inner join Nomina.tblCatTiposLayoutParametros ctlp  
						on ctlp.IDTipoLayout = lp.IDTipoLayout  
							and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
				where lp.IDLayoutPago = @IDLayoutPago  
					and ctlp.Parametro = 'Correo'
			-- CARGAR PARAMETROS EN VARIABLES


			-- MARCAR EMPLEADOS COMO PAGADOS
			if object_id('tempdb..#tempempleadosMarcables') is not null    
				drop table #tempempleadosMarcables;    
    
			create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int); 
    
			if(isnull(@MarcarPagados,0) = 1)
			BEGIN 
				insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago)
					SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago
						FROM  @empleados e     
							INNER join Nomina.tblCatPeriodos p    
								on p.IDPeriodo = @IDPeriodo   
							INNER JOIN RH.tblPagoEmpleado pe    
								on pe.IDEmpleado = e.IDEmpleado
							LEFT join Sat.tblCatBancos b  
								on pe.IDBanco = b.IDBanco    
							INNER JOIN  Nomina.tblLayoutPago lp    
								on lp.IDLayoutPago = pe.IDLayoutPago    
							INNER JOIN Nomina.tblCatTiposLayout tl    
								--on tl.TipoLayout = 'SCOTIABANK'    
								on lp.IDTipoLayout = tl.IDTipoLayout    
							INNER JOIN Nomina.tblDetallePeriodo dp    
								on dp.IDPeriodo = @IDPeriodo    
									--and lp.IDConcepto = dp.IDConcepto  
									and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
										and dp.IDEmpleado = e.IDEmpleado    
					WHERE  pe.IDLayoutPago = @IDLayoutPago
						AND pe.Cuenta IS NOT NULL

				MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET
					USING #tempempleadosMarcables AS SOURCE
						ON TARGET.IDPeriodo = SOURCE.IDPeriodo
							and TARGET.IDEmpleado = SOURCE.IDEmpleado
								and TARGET.IDLayoutPago = SOURCE.IDLayoutPago
					WHEN NOT MATCHED BY TARGET THEN 
					INSERT(IDEmpleado,IDPeriodo,IDLayoutPago)  
				VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDLayoutPago);

			END
			-- MARCAR EMPLEADOS COMO PAGADOS			


			if object_id('tempdb..#tempResp') is not null    
				drop table #tempResp;    
    
			create table #tempResp(Respuesta nvarchar(max));   

			insert into #tempResp(Respuesta)    
				select  
				        [App].[fnAddString](3,'LTX','',1) 
						+[App].[fnAddString](13,@NoCuenta,'0',1)
						+[App].[fnAddString](7,'',' ',1)
						+[App].[fnAddString](18,pe.Cuenta,'0',1)
						+[App].[fnAddString](7,isnull(b.ClaveTransferSantander,''),' ',1)
						+[App].[fnAddString](40,isnull(e.Paterno,'')+' '+isnull(e.Materno,'')+' '+(isnull(E.Nombre,'') + ' ' + isnull(e.SegundoNombre,'')) COLLATE Cyrillic_General_CI_AI,'',2) 
						+[App].[fnAddString](4,'0101','',1)
						+[App].[fnAddString](18,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1) --importe
						+[App].[fnAddString](5,'01001','',1)
						+[App].[fnAddString](40,@TipoPago,' ',2)
						+[App].[fnAddString](7,'161020',' ',2)
						+[App].[fnAddString](40,@Correo,' ',2)
						+[App].[fnAddString](10,'1',' ',2)
					/*CASE WHEN ( e.SegundoNombre IS NULL ) OR ( isnull(e.SegundoNombre,'') = '' ) OR ( isnull(e.SegundoNombre,'') = ' ' ) THEN 
						[App].[fnAddString](1,'2','',2)  --Tipo de Registro						
						+[App].[fnAddString](5, Row_Number()OVER(ORDER BY (SELECT 1)) + 1 ,'0',1 )
						+[App].[fnAddString](7,e.ClaveEmpleado,'0',1)  --Clave Trabajador	
						+[App].[fnAddString](30,isnull(e.Paterno,''),' ',2)  --Apellido Paterno
						+[App].[fnAddString](20,isnull(e.Materno,''),' ',2)  --Apellido Materno
						+[App].[fnAddString](30,(isnull(E.Nombre,'') ) COLLATE Cyrillic_General_CI_AI,'',2)   --Nombre
						+[App].[fnAddString](16,pe.Cuenta,' ',2) --Numero de Cuenta
						+[App].[fnAddString](18,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1)  --Importe 
					ELSE
						[App].[fnAddString](1,'2','',2)  --Tipo de Registro
						+[App].[fnAddString](5,Row_Number()OVER(ORDER BY (SELECT 1)) + 1 ,'0',1) --Contador (Num de fila) 
						+[App].[fnAddString](7,e.ClaveEmpleado,'0',1)  --Clave Trabajador	
						+[App].[fnAddString](30,isnull(e.Paterno,''),' ',2)  --Apellido Paterno
						+[App].[fnAddString](20,isnull(e.Materno,''),' ',2)  --Apellido Materno
						+[App].[fnAddString](30,(isnull(E.Nombre,'') + ' ' + isnull(e.SegundoNombre,'')) COLLATE Cyrillic_General_CI_AI,'',2)   --Nombre
						+[App].[fnAddString](16,pe.Cuenta,' ',2) --Numero de Cuenta
						+[App].[fnAddString](18,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1)  --Importe 
					END*/
				FROM  @empleados e     
					INNER join Nomina.tblCatPeriodos p    
						on p.IDPeriodo = @IDPeriodo   
					INNER JOIN RH.tblPagoEmpleado pe    
						on pe.IDEmpleado = e.IDEmpleado
					left join Sat.tblCatBancos b  
						on pe.IDBanco = b.IDBanco    
					INNER JOIN  Nomina.tblLayoutPago lp    
						on lp.IDLayoutPago = pe.IDLayoutPago    
					inner join Nomina.tblCatTiposLayout tl    
						--on tl.TipoLayout = 'SCOTIABANK'    
						on lp.IDTipoLayout = tl.IDTipoLayout    
					INNER JOIN Nomina.tblDetallePeriodo dp    
						on dp.IDPeriodo = @IDPeriodo    
							--and lp.IDConcepto = dp.IDConcepto
							and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
								and dp.IDEmpleado = e.IDEmpleado    
				where  pe.IDLayoutPago = @IDLayoutPago    
						AND pe.Cuenta IS NOT NULL
			 										

			-- SALIDA

			select * from #tempResp

	END
GO
