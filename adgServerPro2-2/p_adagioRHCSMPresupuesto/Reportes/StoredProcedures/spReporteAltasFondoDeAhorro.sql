USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAltasFondoDeAhorro](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
    	
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

    DECLARE
        @empleados [RH].[dtEmpleados]
        ,@IDTipoNomina INT
        ,@FechaIni DATE
        ,@FechaFin DATE
    ;

    SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
    
    select @FechaIni = CAST(CASE 
                            WHEN ISNULL(Value,'') = '' 
                            THEN '1900-01-01' ELSE  Value 
                            END as date)
	from @dtFiltros where Catalogo = 'FechaIni'
	
    select @FechaFin = CAST(CASE 
                            WHEN ISNULL(Value,'') = ''   
                            THEN '9999-12-31' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaFin'

    insert into @empleados                  
        exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @FechaIni, @Fechafin= @fechaFin, @dtFiltros = @dtFiltros,@IDUsuario = @IDUsuario


   SELECT 
    SUBSTRING(emp.ClaveEmpleado,1,20)
   ,SUBSTRING(ISNULL(emp.Paterno,'.'),1,20)
   ,SUBSTRING(ISNULL(emp.Materno,'.'),1,20)
   ,SUBSTRING(ISNULL(CONCAT(emp.Nombre,CASE WHEN emp.SegundoNombre is null 
                             THEN ''
                             ELSE ' '
                             END
                            ,ISNULL(emp.SegundoNombre,'')),'.'),1,50)
   ,SUBSTRING(ISNULL( CASE WHEN emp.Sexo='MASCULINO' THEN 'M'
                 WHEN emp.Sexo='FEMENINO'  THEN 'F'
                 END
       ,'.'),1,1)
   ,SUBSTRING(ISNULL(CONVERT(varchar,emp.FechaNacimiento,112),'.'),1,8)
   ,SUBSTRING(ISNULL(emp.RFC,'.'),1,20)
   ,SUBSTRING(ISNULL(emp.CURP,'.'),1,20)
   ,SUBSTRING(ISNULL(con.value,'.'),1,50)
   ,SUBSTRING(ISNULL(CASE WHEN emp.EMPRESA='AGAVERA SAN ROMAN S.D. R.L. DE C.V.' THEN '2'
                WHEN emp.EMPRESA='TEQUILA SAN MATIAS DE JALISCO S.A. DE C.V' THEN '1'
           ELSE '0'
           END
       ,'.'),1,20)
   ,SUBSTRING(ISNULL(CONVERT(varchar,emp.FechaAntiguedad,112),'.'),1,8)
   ,'.'
   ,'.'
   ,SUBSTRING(ISNULL(CONVERT(varchar,emp.FechaAntiguedad,112),'.'),1,8)
   ,'FA'
   FROM @empleados emp
   LEFT JOIN RH.TBLCONTACTOEMPLEADO con ON emp.IDEmpleado=CON.IDEmpleado AND IDTipoContactoEmpleado=1
   --LEFT JOIN RH.tblEmpresaEmpleado RS ON EMP.IDEmpleado=RS.IDEMPLEADO AND RS.FechaFin='9999-12-31'

GO
