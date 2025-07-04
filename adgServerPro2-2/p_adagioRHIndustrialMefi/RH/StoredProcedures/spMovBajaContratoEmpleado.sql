USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Ajusta el contrato al realizar una baja desde el perfil del colaborador y reacomoda los contratos.
** Autor			: Jcastillo
** Email			: jcastillo@adagio.com.mx
** FechaCreacion	: 2024-08-29
** Paremetros		:              
** Versión 1 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
    
CREATE   PROCEDURE [RH].[spMovBajaContratoEmpleado]
(          
	  @FechaBaja DATE      
	 ,@IDEmpleado INT          	
	 ,@IDUsuario INT          
)          
AS          
BEGIN     
      IF EXISTS(   SELECT 1 FROM RH.tblContratoEmpleado ce 
                    INNER JOIN RH.tblCatDocumentos d 
                        ON ce.IDDocumento = d.IDDocumento 
                        AND ISNULL(d.EsContrato,0) = 1 
                   WHERE ce.IDEmpleado = @IDEmpleado 
                   AND @FechaBaja BETWEEN ce.FechaIni AND ce.FechaFin  )
		BEGIN	
		
            Declare @Duracion int

            Select @Duracion = DATEDIFF(day,ce.FechaIni,@FechaBaja) + 1 FROM RH.tblContratoEmpleado ce 
				inner join RH.tblCatDocumentos d 
					on ce.IDDocumento = d.IDDocumento 
					and ISNULL(d.EsContrato,0) = 1 
			where ce.IDEmpleado = @IDEmpleado and @FechaBaja Between ce.FechaIni and ce.FechaFin
         

			update CE
				set ce.FechaFin = @FechaBaja
                   ,ce.Duracion = @Duracion 
			FROM RH.tblContratoEmpleado ce 
				inner join RH.tblCatDocumentos d 
					on ce.IDDocumento = d.IDDocumento 
					and ISNULL(d.EsContrato,0) = 1 
			where ce.IDEmpleado = @IDEmpleado and @FechaBaja Between ce.FechaIni and ce.FechaFin

		END

        ELSE 
        BEGIN
        
            RAISERROR ('La fecha de baja del movimiento es menor al inicio del contrato; Revisar historial de contratos.', 16, 1);  
			RETURN 0; 
            
        END
	         
		if OBJECT_ID('tempdb..#tblTempHistorial1') is not null drop table #tblTempHistorial1;          
		if OBJECT_ID('tempdb..#tblTempHistorial2') is not null drop table #tblTempHistorial2;          
          
		select ce.*,isnull(d.EsContrato,0)EsContrato, ROW_NUMBER()over(order by ce.FechaIni asc) as [Row]          
		INTO #tblTempHistorial1          
		FROM RH.tblContratoEmpleado ce with (nolock)
			inner join RH.tblCatDocumentos d with (nolock)
				on d.IDDocumento  = ce.IDDocumento        
		WHERE ce.IDEmpleado = @IDEmpleado and ISNULL(d.EsContrato,0) = 1        
		order by ce.FechaIni asc          
          
		select           
			 t1.IDContratoEmpleado          
			,t1.IDEmpleado          
			,t1.IDDocumento          
			,t1.IDTipoContrato          
			,t1.IDTipoTrabajador          
			,t1.FechaIni     
			,t1.EsContrato         
			,FechaFin = case when t2.FechaIni is not null then 
                                                          case when t2.FechaIni between t1.FechaIni and t1.FechaFin then dateadd(day,-1,t2.FechaIni) 
                                                               else dateadd(day,t1.Duracion -1 ,t1.FechaIni) end 
                                                                   
                             when t1.IDTipoContrato <> 1 then dateadd(day,t1.Duracion -1 ,t1.FechaIni)       
                             else dateadd(day,t1.Duracion -1 ,t1.FechaIni) end            
		INTO #tblTempHistorial2          
		from #tblTempHistorial1 t1          
			left join (select *           
						from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)        


		update [TARGET]          
		set           
			[TARGET].FechaFin = [SOURCE].FechaFin,
            [TARGET].Duracion = @Duracion        
		FROM RH.tblContratoEmpleado as [TARGET]          
			join #tblTempHistorial2 as [SOURCE] on [TARGET].IDContratoEmpleado = [SOURCE].IDContratoEmpleado          
		where ISNULL(SOURCE.EsContrato,0) = 1
	END
GO
