USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblDetalleConfrontaEMASUA](
	[IDDetalleConfrontaSUA] [int] IDENTITY(1,1) NOT NULL,
	[IDControlConfrontaIMSS] [int] NOT NULL,
	[NSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Dias] [int] NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[CuotaFija] [decimal](18, 2) NULL,
	[Excedentes] [decimal](18, 2) NULL,
	[PrestacionesDinero] [decimal](18, 2) NULL,
	[GastosMedicosPensionados] [decimal](18, 2) NULL,
	[RiesgoTrabajo] [decimal](18, 2) NULL,
	[InvalidezVida] [decimal](18, 2) NULL,
	[GuarderiasPrestacionesSociales] [decimal](18, 2) NULL,
	[Total] [decimal](18, 2) NULL,
 CONSTRAINT [PK_IMSStblDetalleConfrontaEMASUA_IDDEtalleConfrontaSUA] PRIMARY KEY CLUSTERED 
(
	[IDDetalleConfrontaSUA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [IMSS].[tblDetalleConfrontaEMASUA]  WITH CHECK ADD  CONSTRAINT [FK_IMSSTblControlConfrontaIMSS_IMSStblDetalleConfrontaEMASUA_IDControlConfrontaIMSS] FOREIGN KEY([IDControlConfrontaIMSS])
REFERENCES [IMSS].[tblControlConfrontaIMSS] ([IDControlConfrontaIMSS])
GO
ALTER TABLE [IMSS].[tblDetalleConfrontaEMASUA] CHECK CONSTRAINT [FK_IMSSTblControlConfrontaIMSS_IMSStblDetalleConfrontaEMASUA_IDControlConfrontaIMSS]
GO
