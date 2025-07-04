USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblControlConfrontaIMSS](
	[IDControlConfrontaIMSS] [int] IDENTITY(1,1) NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[IDMes] [int] NULL,
	[IDBimestre] [int] NULL,
	[EMA] [bit] NULL,
	[EBA] [bit] NULL,
	[FechaHoraRegistro] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
	[Ejercicio] [int] NULL,
 CONSTRAINT [PK_IMSSTblControlConfrontaIMSS_IDControlConfrontaIMSS] PRIMARY KEY CLUSTERED 
(
	[IDControlConfrontaIMSS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [IMSS].[tblControlConfrontaIMSS] ADD  CONSTRAINT [d_IMSSTblControlConfrontaIMSS_FechaHora]  DEFAULT (getdate()) FOR [FechaHoraRegistro]
GO
ALTER TABLE [IMSS].[tblControlConfrontaIMSS]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatBimestres_ImssTblControlConfrontaIMSS_IDBimestre] FOREIGN KEY([IDBimestre])
REFERENCES [Nomina].[tblCatBimestres] ([IDBimestre])
GO
ALTER TABLE [IMSS].[tblControlConfrontaIMSS] CHECK CONSTRAINT [FK_NominaTblCatBimestres_ImssTblControlConfrontaIMSS_IDBimestre]
GO
ALTER TABLE [IMSS].[tblControlConfrontaIMSS]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatMeses_ImssTblControlConfrontaIMSS_IDMes] FOREIGN KEY([IDMes])
REFERENCES [Nomina].[tblCatMeses] ([IDMes])
GO
ALTER TABLE [IMSS].[tblControlConfrontaIMSS] CHECK CONSTRAINT [FK_NominaTblCatMeses_ImssTblControlConfrontaIMSS_IDMes]
GO
ALTER TABLE [IMSS].[tblControlConfrontaIMSS]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRegPatronal_IMSSTblControlConfrontaIMSS_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [IMSS].[tblControlConfrontaIMSS] CHECK CONSTRAINT [FK_RHTblCatRegPatronal_IMSSTblControlConfrontaIMSS_IDRegPatronal]
GO
ALTER TABLE [IMSS].[tblControlConfrontaIMSS]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_IMSSTblControlConfrontaIMSS_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [IMSS].[tblControlConfrontaIMSS] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_IMSSTblControlConfrontaIMSS_IDUsuario]
GO
